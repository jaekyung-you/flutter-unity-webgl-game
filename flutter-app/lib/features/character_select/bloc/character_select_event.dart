import 'package:equatable/equatable.dart';

abstract class CharacterSelectEvent extends Equatable {
  const CharacterSelectEvent();
  @override
  List<Object?> get props => [];
}

class CharacterSelectLoadRequested extends CharacterSelectEvent {
  const CharacterSelectLoadRequested();
}

class CharacterChanged extends CharacterSelectEvent {
  final String character;
  const CharacterChanged(this.character);
  @override
  List<Object?> get props => [character];
}

class CharacterConfirmed extends CharacterSelectEvent {
  const CharacterConfirmed();
}
