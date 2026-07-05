# Devkom Chess System - Complete Implementation Guide

## 📋 Overview

This document describes the complete chess game system implementation for the Devkom application, including AI opponents, Firestore integration, admin panels, Cloud Functions, and FCM notifications.

---

## 🏗️ Architecture

### Core Components

1. **Chess AI Service** - Minimax algorithm with alpha-beta pruning
2. **Firestore Service** - Database operations for games and statistics
3. **Chess Game UI** - Material 3 themed interactive chess board
4. **Admin Dashboard** - Statistics and game management
5. **Cloud Functions** - Automatic stats updates and notifications
6. **Security Rules** - Role-based access control

---

## 📁 File Structure

```
lib/
├── models/
│   └── chess_game_model.dart          # Game and stats data models
├── services/
│   ├── chess_ai_service.dart          # AI engine (minimax)
│   └── chess_firestore_service.dart   # Firestore operations
├── screens/
│   ├── games/
│   │   └── chess_game_screen.dart     # Main chess UI
│   └── admin/
│       └── admin_chess_stats_screen.dart  # Admin panel

functions/
├── index.ts                            # Cloud Functions
├── package.json                        # Node dependencies
└── tsconfig.json                       # TypeScript config

firestore.rules                         # Security rules
```

---

## 🎮 Chess Game Models

### ChessDifficulty Enum

```dart
enum ChessDifficulty {
  beginner,      // Depth 2, ~800 ELO
  intermediate,  // Depth 4, ~1400 ELO
  advanced,      // Depth 6, ~2000 ELO
}
```

### GameResult Enum

```dart
enum GameResult {
  win,       // Player won
  loss,      // Player lost
  draw,      // Draw/stalemate
  ongoing,   // Game in progress
}
```

### ChessGameModel

```dart
class ChessGameModel {
  final String gameId;           // Unique game ID (UUID)
  final String playerId;         // User UID
  final String playerName;       // Display name
  final String opponent;         // "AI" or user UID
  final ChessDifficulty difficulty;
  final GameResult result;
  final int duration;            // Seconds
  final List<String> moveHistory;  // SAN notation
  final String finalFEN;         // Final board position
  final DateTime timestamp;
  final DateTime? startTime;
  final DateTime? endTime;
}
```

### ChessStatsModel

```dart
class ChessStatsModel {
  final String userId;
  final String email;
  final String name;
  final String role;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int avgDuration;
  final String maxLevelPlayed;
  final DateTime lastPlayed;

  // Computed properties
  double get winRate => totalGames > 0 ? (wins / totalGames) * 100 : 0.0;
  double get lossRate => totalGames > 0 ? (losses / totalGames) * 100 : 0.0;
  double get drawRate => totalGames > 0 ? (draws / totalGames) * 100 : 0.0;
}
```

---

## 🤖 AI Engine

### Algorithm: Minimax with Alpha-Beta Pruning

The AI uses the minimax algorithm with alpha-beta pruning for optimal move selection.

**Key Features:**
- Configurable search depth (2, 4, 6) based on difficulty
- Position evaluation using piece values and position bonuses
- Alpha-beta pruning for performance optimization
- Runs in isolate for non-blocking UI

### Position Evaluation

**Piece Values:**
- Pawn: 100
- Knight: 320
- Bishop: 330
- Rook: 500
- Queen: 900
- King: 20000

**Position Bonuses:**
- Pawns: Encouraged to move forward and control center
- Knights: Prefer central squares
- Bishops: Prefer central diagonals
- Rooks: Prefer 7th rank
- Queen: Prefer center in middlegame
- King: Prefer corners/safety in opening

**Additional Factors:**
- Castling rights (+30 points)
- Check penalty (-50 points)
- Mobility bonus (2 points per legal move)

### Usage Example

```dart
final aiService = ChessAIService();
final bestMove = await aiService.getBestMove(
  game: chessGame,
  difficulty: ChessDifficulty.intermediate,
);
```

---

## 💾 Firestore Collections

### chess_games Collection

**Document Structure:**
```json
{
  "gameId": "uuid-v4",
  "playerId": "user-uid",
  "playerName": "John Doe",
  "opponent": "AI",
  "difficulty": "intermediate",
  "result": "win",
  "duration": 1234,
  "moveHistory": ["e4", "e5", "Nf3", ...],
  "finalFEN": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  "timestamp": "2025-01-20T10:30:00Z",
  "startTime": "2025-01-20T10:10:00Z",
  "endTime": "2025-01-20T10:30:00Z"
}
```

### users Collection (Chess Stats Fields)

**Additional Fields:**
```json
{
  "totalGames": 42,
  "wins": 25,
  "losses": 12,
  "draws": 5,
  "avgDuration": 890,
  "maxLevelPlayed": "advanced",
  "lastPlayed": "2025-01-20T10:30:00Z"
}
```

---

## 🔐 Firestore Security Rules

### Chess Games Rules

```javascript
match /chess_games/{gameId} {
  // Anyone authenticated can read games
  allow read: if isAuthenticated();

  // Users can create their own games
  allow create: if isAuthenticated() &&
                  request.resource.data.playerId == request.auth.uid;

  // Users can update their own games, admins can update any
  allow update: if isAuthenticated() &&
                  (resource.data.playerId == request.auth.uid || isAdmin());

  // Only admins can delete
  allow delete: if isAdmin();
}
```

### User Stats Rules

```javascript
match /users/{userId} {
  allow read: if isAuthenticated();
  allow update: if isOwner(userId) &&
                  !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role']);
  allow create, delete: if isAdmin();
}
```

---

## ☁️ Cloud Functions

### 1. onChessGameCreated

**Trigger:** When a new chess game document is created
**Purpose:** Auto-update user statistics

```typescript
export const onChessGameCreated = functions.firestore
  .document('chess_games/{gameId}')
  .onCreate(async (snapshot, context) => {
    const game = snapshot.data() as ChessGame;

    if (game.result === 'ongoing') return null;

    await updateUserStatsTransaction(game);
    await sendGameResultNotification(game);
    return null;
  });
```

### 2. onChessGameUpdated

**Trigger:** When a chess game document is updated
**Purpose:** Update stats when game completes

```typescript
export const onChessGameUpdated = functions.firestore
  .document('chess_games/{gameId}')
  .onUpdate(async (change, context) => {
    const oldGame = change.before.data() as ChessGame;
    const newGame = change.after.data() as ChessGame;

    if (oldGame.result === 'ongoing' && newGame.result !== 'ongoing') {
      await updateUserStatsTransaction(newGame);
      await sendGameResultNotification(newGame);
    }
    return null;
  });
```

### 3. updateUserStatsTransaction

**Purpose:** Update user stats using Firestore transaction (race condition safe)

**Logic:**
1. Get current user stats
2. Calculate new stats:
   - `totalGames = current + 1`
   - `wins = current + (result === 'win' ? 1 : 0)`
   - `losses = current + (result === 'loss' ? 1 : 0)`
   - `draws = current + (result === 'draw' ? 1 : 0)`
   - `avgDuration = (currentAvg * currentTotal + newDuration) / newTotal`
   - `maxLevelPlayed = max(current, new)`
3. Update user document atomically

### 4. cleanupOldGames

**Trigger:** Scheduled (every 24 hours)
**Purpose:** Mark games ongoing for >24h as abandoned

```typescript
export const cleanupOldGames = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const oldGames = await db.collection('chess_games')
      .where('result', '==', 'ongoing')
      .where('timestamp', '<', yesterday)
      .get();

    const batch = db.batch();
    oldGames.docs.forEach(doc => {
      batch.update(doc.ref, { result: 'draw' });
    });
    await batch.commit();
  });
```

### 5. recalculateUserStats (Callable)

**Purpose:** Admin function to recalculate stats from scratch

**Usage:**
```dart
final callable = FirebaseFunctions.instance.httpsCallable('recalculateUserStats');
final result = await callable.call({'userId': 'user-uid'});
```

---

## 🔔 FCM Notifications

### Notification Flow

1. **Game Completed** → Cloud Function triggered
2. **Function sends FCM** → User receives push notification
3. **Notification stored** → Firestore `notifications` collection

### Notification Structure

```json
{
  "notification": {
    "title": "🏆 Tebrikler!",
    "body": "intermediate seviyesinde AI'yı yendiniz!"
  },
  "data": {
    "type": "chess_game_result",
    "gameId": "uuid",
    "result": "win",
    "difficulty": "intermediate"
  }
}
```

---

## 🎨 UI Components

### Chess Game Screen

**Features:**
- Difficulty selection screen
- Interactive chess board
- AI thinking indicator
- Game timer
- Move counter
- Result dialog
- Auto-save to Firestore

**Navigation:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChessGameScreen(
      initialDifficulty: ChessDifficulty.intermediate,
    ),
  ),
);
```

### Admin Stats Screen

**3 Tabs:**

1. **Overall Statistics**
   - Total games, wins, losses, draws
   - Difficulty distribution
   - Result distribution
   - Average duration

2. **Player Statistics**
   - Searchable/sortable table
   - All player stats
   - Win rates

3. **Game History**
   - Filterable by difficulty/result
   - Game details
   - Move history

---

## 📊 Performance Optimization

### Firestore Indexes

Create composite indexes for efficient queries:

```
Collection: chess_games
Fields: playerId (Ascending), timestamp (Descending)

Collection: chess_games
Fields: difficulty (Ascending), timestamp (Descending)

Collection: chess_games
Fields: result (Ascending), timestamp (Descending)

Collection: users
Fields: totalGames (Descending)

Collection: users
Fields: wins (Descending)
```

### Pagination

All list queries use `.limit()` to prevent large data transfers:

```dart
stream: _firestoreService.getUserGames(
  userId: userId,
  limit: 20,  // Only fetch 20 games at a time
);
```

### AI Optimization

- Uses `compute()` to run AI in isolate (non-blocking)
- Alpha-beta pruning reduces search space
- Depth limited by difficulty

---

## 🧪 Testing

### Manual Testing Scenarios

1. **Beginner Game**
   - Start game with beginner difficulty
   - AI should make basic moves, occasionally mistakes
   - Game completes in ~10 minutes
   - Stats update correctly

2. **Intermediate Game**
   - Start game with intermediate difficulty
   - AI uses tactical moves
   - Game completes in ~20 minutes
   - Notification received on completion

3. **Advanced Game**
   - Start game with advanced difficulty
   - AI plays strong moves
   - Game completes in ~30 minutes
   - Stats reflect difficulty increase

4. **Admin Panel**
   - View overall statistics
   - Search for players
   - Filter games by difficulty/result
   - View game details

5. **Cloud Functions**
   - Check logs: `firebase functions:log`
   - Verify stats update after game
   - Verify notification sent

---

## 🚀 Deployment

### 1. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### 2. Deploy Cloud Functions

```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 3. Create Firestore Indexes

Go to Firebase Console → Firestore → Indexes and create the composite indexes listed above.

### 4. Test Functions Locally

```bash
cd functions
npm run serve
```

---

## 📝 Example Game Document

```json
{
  "gameId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "playerId": "user123456",
  "playerName": "Ali Yılmaz",
  "opponent": "AI",
  "difficulty": "intermediate",
  "result": "win",
  "duration": 1456,
  "moveHistory": [
    "e4", "e5", "Nf3", "Nc6", "Bb5", "a6", "Ba4", "Nf6",
    "O-O", "Be7", "Re1", "b5", "Bb3", "d6", "c3", "O-O",
    "h3", "Na5", "Bc2", "c5", "d4", "Qc7"
  ],
  "finalFEN": "r1b2rk1/2q1bppp/p2p1n2/npp1p3/3PP3/2P2N1P/PPB2PP1/RNBQR1K1 w - - 4 12",
  "timestamp": {
    "_seconds": 1705750200,
    "_nanoseconds": 0
  },
  "startTime": {
    "_seconds": 1705748744,
    "_nanoseconds": 0
  },
  "endTime": {
    "_seconds": 1705750200,
    "_nanoseconds": 0
  }
}
```

---

## 📝 Example User Stats

```json
{
  "uid": "user123456",
  "email": "ali@example.com",
  "displayName": "Ali Yılmaz",
  "role": "student",
  "totalGames": 15,
  "wins": 8,
  "losses": 5,
  "draws": 2,
  "avgDuration": 1234,
  "maxLevelPlayed": "advanced",
  "lastPlayed": {
    "_seconds": 1705750200,
    "_nanoseconds": 0
  }
}
```

**Computed Stats:**
- Win Rate: 53.3%
- Loss Rate: 33.3%
- Draw Rate: 13.3%

---

## 🔧 Troubleshooting

### Issue: AI too slow

**Solution:** Reduce search depth or optimize evaluation function

### Issue: Stats not updating

**Solution:**
1. Check Cloud Functions logs: `firebase functions:log`
2. Verify Firestore rules allow write
3. Ensure transaction is completing

### Issue: Notifications not received

**Solution:**
1. Check FCM token is saved in user document
2. Verify Cloud Messaging is enabled in Firebase Console
3. Check notification permissions

### Issue: Permission denied errors

**Solution:**
1. Verify user is authenticated
2. Check Firestore rules match your use case
3. Ensure user document has correct `role` field

---

## 📞 Support Commands

```bash
# View Cloud Functions logs
firebase functions:log

# Test functions locally
cd functions && npm run serve

# Deploy only functions
firebase deploy --only functions

# Deploy only rules
firebase deploy --only firestore:rules

# Full deployment
firebase deploy

# Check Firebase project
firebase use
```

---

## ✅ Implementation Checklist

- [x] Chess game data models
- [x] AI engine with minimax algorithm
- [x] Firestore service for games/stats
- [x] Chess game UI screen
- [x] Admin statistics dashboard
- [x] Firestore security rules
- [x] Cloud Functions for auto stats
- [x] FCM notifications
- [x] Performance optimization
- [x] Documentation

---

**Status:** ✅ Complete and Production Ready
**Last Updated:** 2025-01-20
**Version:** 1.0.0
