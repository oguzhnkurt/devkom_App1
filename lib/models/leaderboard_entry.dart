// TODO: Migrate to Supabase - import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int score;
  final int rank;
  final String gameId;
  final String? gameName;
  final DateTime achievedAt;
  final Map<String, dynamic>? metadata; // Ekstra bilgiler (level, time, etc.)

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.score,
    required this.rank,
    required this.gameId,
    this.gameName,
    required this.achievedAt,
    this.metadata,
  });

  // TODO: Migrate to Supabase
  // factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return LeaderboardEntry(
  //     userId: data['userId'] ?? '',
  //     userName: data['userName'] ?? 'Anonim',
  //     userPhotoUrl: data['userPhotoUrl'],
  //     score: data['score'] ?? 0,
  //     rank: data['rank'] ?? 0,
  //     gameId: data['gameId'] ?? '',
  //     gameName: data['gameName'],
  //     achievedAt: (data['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  //     metadata: data['metadata'],
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'score': score,
      'rank': rank,
      'gameId': gameId,
      'gameName': gameName,
      'achievedAt': achievedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? userName,
    String? userPhotoUrl,
    int? score,
    int? rank,
    String? gameId,
    String? gameName,
    DateTime? achievedAt,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      achievedAt: achievedAt ?? this.achievedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class GlobalLeaderboardEntry {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int totalScore;
  final int rank;
  final int gamesPlayed;
  final Map<String, int> gameScores; // gameId -> score

  GlobalLeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.totalScore,
    required this.rank,
    required this.gamesPlayed,
    required this.gameScores,
  });

  // TODO: Migrate to Supabase
  // factory GlobalLeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return GlobalLeaderboardEntry(
  //     userId: data['userId'] ?? '',
  //     userName: data['userName'] ?? 'Anonim',
  //     userPhotoUrl: data['userPhotoUrl'],
  //     totalScore: data['totalScore'] ?? 0,
  //     rank: data['rank'] ?? 0,
  //     gamesPlayed: data['gamesPlayed'] ?? 0,
  //     gameScores: Map<String, int>.from(data['gameScores'] ?? {}),
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'totalScore': totalScore,
      'rank': rank,
      'gamesPlayed': gamesPlayed,
      'gameScores': gameScores,
    };
  }
}
