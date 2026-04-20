import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/score_repository.dart';
import 'character_select_event.dart';
import 'character_select_state.dart';

class CharacterSelectBloc
    extends Bloc<CharacterSelectEvent, CharacterSelectState> {
  final ScoreRepository _repo;

  CharacterSelectBloc(this._repo) : super(const CharacterSelectState()) {
    on<CharacterSelectLoadRequested>(_onLoad);
    on<CharacterChanged>(_onChange);
    on<CharacterConfirmed>(_onConfirm);
  }

  Future<void> _onLoad(
      CharacterSelectLoadRequested event, Emitter<CharacterSelectState> emit) async {
    final c = await _repo.getSelectedCharacter();
    emit(state.copyWith(selectedCharacter: c));
  }

  void _onChange(CharacterChanged event, Emitter<CharacterSelectState> emit) {
    emit(state.copyWith(selectedCharacter: event.character));
  }

  Future<void> _onConfirm(
      CharacterConfirmed event, Emitter<CharacterSelectState> emit) async {
    await _repo.saveSelectedCharacter(state.selectedCharacter);
  }
}
