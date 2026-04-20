import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameUnityReady extends GameEvent {
  const GameUnityReady();
}

class GameStarted extends GameEvent {
  const GameStarted();
}

class GameRestarted extends GameEvent {
  const GameRestarted();
}

class GameScoreUpdated extends GameEvent {
  final int score;
  const GameScoreUpdated(this.score);
  @override
  List<Object?> get props => [score];
}

class GameBurnoutUpdated extends GameEvent {
  final int current;
  final int max;
  const GameBurnoutUpdated(this.current, this.max);
  @override
  List<Object?> get props => [current, max];
}

class GameDodgeUpdated extends GameEvent {
  final int count;
  const GameDodgeUpdated(this.count);
  @override
  List<Object?> get props => [count];
}

class GameOver extends GameEvent {
  final int finalScore;
  final int bestScore;
  const GameOver(this.finalScore, this.bestScore);
  @override
  List<Object?> get props => [finalScore, bestScore];
}

class GamePauseToggled extends GameEvent {
  const GamePauseToggled();
}
