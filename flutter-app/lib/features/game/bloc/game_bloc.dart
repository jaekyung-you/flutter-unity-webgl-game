import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/game_record.dart';
import '../../../data/repositories/score_repository.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final ScoreRepository _repo;

  GameBloc(this._repo) : super(const GameState()) {
    on<GameUnityReady>(_onUnityReady);
    on<GameStarted>(_onStarted);
    on<GameRestarted>(_onRestarted);
    on<GameScoreUpdated>(_onScoreUpdated);
    on<GameBurnoutUpdated>(_onBurnoutUpdated);
    on<GameDodgeUpdated>(_onDodgeUpdated);
    on<GameOver>(_onGameOver);
    on<GamePauseToggled>(_onPauseToggled);
  }

  void _onUnityReady(GameUnityReady event, Emitter<GameState> emit) {
    emit(state.copyWith(status: GameStatus.ready));
  }

  void _onStarted(GameStarted event, Emitter<GameState> emit) {
    emit(state.copyWith(
        status: GameStatus.playing, score: 0, burnoutCurrent: 0, dodgeCount: 0));
  }

  void _onRestarted(GameRestarted event, Emitter<GameState> emit) {
    emit(state.copyWith(
        status: GameStatus.playing, score: 0, burnoutCurrent: 0, dodgeCount: 0));
  }

  void _onScoreUpdated(GameScoreUpdated event, Emitter<GameState> emit) {
    emit(state.copyWith(score: event.score));
  }

  void _onBurnoutUpdated(GameBurnoutUpdated event, Emitter<GameState> emit) {
    emit(state.copyWith(burnoutCurrent: event.current, burnoutMax: event.max));
  }

  void _onDodgeUpdated(GameDodgeUpdated event, Emitter<GameState> emit) {
    emit(state.copyWith(dodgeCount: event.count));
  }

  Future<void> _onGameOver(GameOver event, Emitter<GameState> emit) async {
    await _repo.addRecord(GameRecord(
      date: DateTime.now(),
      score: event.finalScore,
      dodgeCount: state.dodgeCount,
      burnoutCount: state.burnoutCurrent,
    ));
    final bestScore = await _repo.getBestScore();
    emit(state.copyWith(
      status: GameStatus.gameOver,
      score: event.finalScore,
      bestScore: bestScore,
    ));
  }

  void _onPauseToggled(GamePauseToggled event, Emitter<GameState> emit) {
    final next =
        state.status == GameStatus.paused ? GameStatus.playing : GameStatus.paused;
    emit(state.copyWith(status: next));
  }
}
