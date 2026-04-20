import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/score_repository.dart';
import 'score_event.dart';
import 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final ScoreRepository _repo;

  ScoreBloc(this._repo) : super(const ScoreState()) {
    on<ScoreLoadRequested>(_onLoad);
    on<ScoreClearRequested>(_onClear);
  }

  Future<void> _onLoad(ScoreLoadRequested event, Emitter<ScoreState> emit) async {
    final records = await _repo.getRecords();
    emit(state.copyWith(status: ScoreStatus.loaded, records: records));
  }

  Future<void> _onClear(ScoreClearRequested event, Emitter<ScoreState> emit) async {
    await _repo.clearAll();
    emit(state.copyWith(status: ScoreStatus.loaded, records: []));
  }
}
