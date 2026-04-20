import 'package:equatable/equatable.dart';

abstract class ScoreEvent extends Equatable {
  const ScoreEvent();
  @override
  List<Object?> get props => [];
}

class ScoreLoadRequested extends ScoreEvent {
  const ScoreLoadRequested();
}

class ScoreClearRequested extends ScoreEvent {
  const ScoreClearRequested();
}
