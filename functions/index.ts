/**
 * Firebase Cloud Functions for Devkom Chess System
 * Auto-updates user statistics when chess games are created/updated
 * Uses transactions to prevent race conditions
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

interface ChessGame {
  gameId: string;
  playerId: string;
  playerName: string;
  opponent: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  result: 'win' | 'loss' | 'draw' | 'ongoing';
  duration: number;
  moveHistory: string[];
  finalFEN: string;
  timestamp: admin.firestore.Timestamp;
  startTime?: admin.firestore.Timestamp;
  endTime?: admin.firestore.Timestamp;
}

interface UserStats {
  totalGames: number;
  wins: number;
  losses: number;
  draws: number;
  avgDuration: number;
  maxLevelPlayed: string;
  lastPlayed: admin.firestore.Timestamp;
}

/**
 * Trigger when a new chess game is created
 * Automatically updates user statistics
 */
export const onChessGameCreated = functions.firestore
  .document('chess_games/{gameId}')
  .onCreate(async (snapshot, context) => {
    const game = snapshot.data() as ChessGame;

    console.log(`📊 New chess game created: ${game.gameId}`);

    // Only update stats if game is completed
    if (game.result === 'ongoing') {
      console.log('⏳ Game is ongoing, skipping stats update');
      return null;
    }

    try {
      await updateUserStatsTransaction(game);
      console.log(`✅ User stats updated for player: ${game.playerId}`);

      // Send notification to player
      await sendGameResultNotification(game);

      return null;
    } catch (error) {
      console.error('❌ Error updating user stats:', error);
      throw error;
    }
  });

/**
 * Trigger when a chess game is updated
 * Updates user statistics when game status changes to completed
 */
export const onChessGameUpdated = functions.firestore
  .document('chess_games/{gameId}')
  .onUpdate(async (change, context) => {
    const oldGame = change.before.data() as ChessGame;
    const newGame = change.after.data() as ChessGame;

    console.log(`📝 Chess game updated: ${newGame.gameId}`);

    // Only update stats if game just completed (was ongoing, now finished)
    if (oldGame.result === 'ongoing' && newGame.result !== 'ongoing') {
      console.log('🏁 Game completed, updating stats');

      try {
        await updateUserStatsTransaction(newGame);
        console.log(`✅ User stats updated for player: ${newGame.playerId}`);

        // Send notification to player
        await sendGameResultNotification(newGame);

        return null;
      } catch (error) {
        console.error('❌ Error updating user stats:', error);
        throw error;
      }
    }

    console.log('⏩ No stats update needed');
    return null;
  });

/**
 * Update user statistics using a transaction to prevent race conditions
 */
async function updateUserStatsTransaction(game: ChessGame): Promise<void> {
  const userRef = db.collection('users').doc(game.playerId);

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      console.warn(`⚠️ User document not found: ${game.playerId}`);
      // Create initial stats
      const initialStats: Partial<UserStats> = {
        totalGames: 1,
        wins: game.result === 'win' ? 1 : 0,
        losses: game.result === 'loss' ? 1 : 0,
        draws: game.result === 'draw' ? 1 : 0,
        avgDuration: game.duration,
        maxLevelPlayed: game.difficulty,
        lastPlayed: game.timestamp,
      };
      transaction.update(userRef, initialStats);
      return;
    }

    const userData = userDoc.data();
    const currentStats: UserStats = {
      totalGames: userData?.totalGames || 0,
      wins: userData?.wins || 0,
      losses: userData?.losses || 0,
      draws: userData?.draws || 0,
      avgDuration: userData?.avgDuration || 0,
      maxLevelPlayed: userData?.maxLevelPlayed || 'beginner',
      lastPlayed: userData?.lastPlayed || admin.firestore.Timestamp.now(),
    };

    // Calculate new stats
    const newTotalGames = currentStats.totalGames + 1;
    const newWins = game.result === 'win' ? currentStats.wins + 1 : currentStats.wins;
    const newLosses = game.result === 'loss' ? currentStats.losses + 1 : currentStats.losses;
    const newDraws = game.result === 'draw' ? currentStats.draws + 1 : currentStats.draws;

    // Calculate new average duration
    const totalDuration = currentStats.avgDuration * currentStats.totalGames + game.duration;
    const newAvgDuration = Math.floor(totalDuration / newTotalGames);

    // Determine max level played
    const newMaxLevel = getHigherDifficulty(currentStats.maxLevelPlayed, game.difficulty);

    // Update user document with new stats
    const updatedStats: Partial<UserStats> = {
      totalGames: newTotalGames,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      avgDuration: newAvgDuration,
      maxLevelPlayed: newMaxLevel,
      lastPlayed: game.timestamp,
    };

    transaction.update(userRef, updatedStats);

    console.log(`📈 Stats updated: ${newTotalGames} games, ${newWins}W ${newLosses}L ${newDraws}D`);
  });
}

/**
 * Determine the higher difficulty level
 */
function getHigherDifficulty(current: string, newLevel: string): string {
  const difficultyOrder = ['beginner', 'intermediate', 'advanced'];
  const currentIndex = difficultyOrder.indexOf(current.toLowerCase());
  const newIndex = difficultyOrder.indexOf(newLevel.toLowerCase());

  return newIndex > currentIndex ? newLevel : current;
}

/**
 * Send FCM notification to player about game result
 */
async function sendGameResultNotification(game: ChessGame): Promise<void> {
  try {
    const userDoc = await db.collection('users').doc(game.playerId).get();

    if (!userDoc.exists) {
      console.warn('⚠️ User not found for notification');
      return;
    }

    const userData = userDoc.data();
    const fcmToken = userData?.fcmToken;

    if (!fcmToken) {
      console.log('ℹ️ No FCM token found for user');
      return;
    }

    let title = '';
    let body = '';

    switch (game.result) {
      case 'win':
        title = '🏆 Tebrikler!';
        body = `${game.difficulty} seviyesinde AI'yı yendiniz!`;
        break;
      case 'loss':
        title = '😔 Maalesef';
        body = `${game.difficulty} seviyesinde AI kazandı. Tekrar deneyin!`;
        break;
      case 'draw':
        title = '🤝 Berabere';
        body = `${game.difficulty} seviyesinde oyun berabere bitti.`;
        break;
    }

    const message = {
      notification: {
        title,
        body,
      },
      data: {
        type: 'chess_game_result',
        gameId: game.gameId,
        result: game.result,
        difficulty: game.difficulty,
      },
      token: fcmToken,
    };

    await messaging.send(message);
    console.log('✅ Notification sent successfully');

    // Create notification document in Firestore
    await db.collection('notifications').add({
      userId: game.playerId,
      type: 'chess_game_result',
      title,
      body,
      data: {
        gameId: game.gameId,
        result: game.result,
        difficulty: game.difficulty,
      },
      read: false,
      createdAt: admin.firestore.Timestamp.now(),
    });
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    // Don't throw error - notification failure shouldn't block stats update
  }
}

/**
 * Scheduled function to clean up old ongoing games (runs daily)
 * Games that have been ongoing for more than 24 hours are marked as abandoned
 */
export const cleanupOldGames = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    console.log('🧹 Running game cleanup...');

    const now = admin.firestore.Timestamp.now();
    const yesterday = new Date(now.toDate().getTime() - 24 * 60 * 60 * 1000);

    try {
      const oldGamesSnapshot = await db
        .collection('chess_games')
        .where('result', '==', 'ongoing')
        .where('timestamp', '<', admin.firestore.Timestamp.fromDate(yesterday))
        .get();

      console.log(`Found ${oldGamesSnapshot.size} old ongoing games`);

      const batch = db.batch();
      oldGamesSnapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          result: 'draw', // Mark as draw/abandoned
          endTime: now,
        });
      });

      await batch.commit();
      console.log(`✅ Cleaned up ${oldGamesSnapshot.size} old games`);

      return null;
    } catch (error) {
      console.error('❌ Error cleaning up old games:', error);
      throw error;
    }
  });

/**
 * Callable function to recalculate user statistics (admin only)
 * Useful for fixing inconsistent data
 */
export const recalculateUserStats = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated and is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const callerDoc = await db.collection('users').doc(context.auth.uid).get();
  const callerData = callerDoc.data();

  if (callerData?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can recalculate stats');
  }

  const userId = data.userId;

  if (!userId) {
    throw new functions.https.HttpsError('invalid-argument', 'userId is required');
  }

  console.log(`🔄 Recalculating stats for user: ${userId}`);

  try {
    // Get all completed games for the user
    const gamesSnapshot = await db
      .collection('chess_games')
      .where('playerId', '==', userId)
      .where('result', '!=', 'ongoing')
      .get();

    let totalGames = 0;
    let wins = 0;
    let losses = 0;
    let draws = 0;
    let totalDuration = 0;
    let maxLevel = 'beginner';
    let lastPlayed = admin.firestore.Timestamp.now();

    gamesSnapshot.docs.forEach((doc) => {
      const game = doc.data() as ChessGame;

      totalGames++;
      if (game.result === 'win') wins++;
      if (game.result === 'loss') losses++;
      if (game.result === 'draw') draws++;

      totalDuration += game.duration;
      maxLevel = getHigherDifficulty(maxLevel, game.difficulty);

      if (game.timestamp.toMillis() > lastPlayed.toMillis()) {
        lastPlayed = game.timestamp;
      }
    });

    const avgDuration = totalGames > 0 ? Math.floor(totalDuration / totalGames) : 0;

    // Update user stats
    await db.collection('users').doc(userId).update({
      totalGames,
      wins,
      losses,
      draws,
      avgDuration,
      maxLevelPlayed: maxLevel,
      lastPlayed,
    });

    console.log(`✅ Stats recalculated for user ${userId}: ${totalGames} games`);

    return {
      success: true,
      totalGames,
      wins,
      losses,
      draws,
      avgDuration,
      maxLevelPlayed: maxLevel,
    };
  } catch (error) {
    console.error('❌ Error recalculating stats:', error);
    throw new functions.https.HttpsError('internal', 'Failed to recalculate stats');
  }
});
