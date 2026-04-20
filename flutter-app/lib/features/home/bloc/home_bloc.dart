import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/score_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ScoreRepository _repo;

  HomeBloc(this._repo) : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    final best = await _repo.getBestScore();
    emit(state.copyWith(bestScore: best));
  }
}
