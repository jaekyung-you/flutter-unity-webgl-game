import 'package:equatable/equatable.dart';

class GameRecord extends Equatable {
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
        score: j['score'] as int,
        dodgeCount: j['dodgeCount'] as int,
        burnoutCount: j['burnoutCount'] as int,
      );

  @override
  List<Object?> get props => [date, score, dodgeCount, burnoutCount];
}
