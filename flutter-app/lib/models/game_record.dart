class GameRecord {
  final DateTime date;
  final int score;
  final int dodgeCount;
  final int burnoutCount;

  const GameRecord({
    required this.date,
    required this.score,
    required this.dodgeCount,
    required this.burnoutCount,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'dodgeCount': dodgeCount,
        'burnoutCount': burnoutCount,
      };

  factory GameRecord.fromJson(Map<String, dynamic> j) => GameRecord(
        date: DateTime.parse(j['date'] as String),
        score: (j['score'] as num?)?.toInt() ?? 0,
        dodgeCount: (j['dodgeCount'] as num?)?.toInt() ?? 0,
        burnoutCount: (j['burnoutCount'] as num?)?.toInt() ?? 0,
      );
}
