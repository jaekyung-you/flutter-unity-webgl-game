import 'package:equatable/equatable.dart';

enum GameStatus { loading, ready, playing, paused, gameOver }

class GameState extends Equatable {
  final GameStatus status;
  final int score;
  final int bestScore;
  final int burnoutCurrent;
  final int burnoutMax;
  final int dodgeCount;

  const GameState({
    this.status = GameStatus.loading,
    this.score = 0,
    this.bestScore = 0,
    this.burnoutCurrent = 0,
    this.burnoutMax = 5,
    this.dodgeCount = 0,
  });

  bool get isPlaying => status == GameStatus.playing;
  bool get isGameOver => status == GameStatus.gameOver;
  bool get isReady => status == GameStatus.ready;
  bool get isPaused => status == GameStatus.paused;

  GameState copyWith({
    GameStatus? status,
    int? score,
    int? bestScore,
    int? burnoutCurrent,
    int? burnoutMax,
    int? dodgeCount,
  }) =>
      GameState(
        status: status ?? this.status,
        score: score ?? this.score,
        bestScore: bestScore ?? this.bestScore,
        burnoutCurrent: burnoutCurrent ?? this.burnoutCurrent,
        burnoutMax: burnoutMax ?? this.burnoutMax,
        dodgeCount: dodgeCount ?? this.dodgeCount,
      );

  @override
  List<Object?> get props =>
      [status, score, bestScore, burnoutCurrent, burnoutMax, dodgeCount];
}
