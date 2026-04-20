import 'package:equatable/equatable.dart';

class CharacterSelectState extends Equatable {
  final String selectedCharacter;

  const CharacterSelectState({this.selectedCharacter = 'male'});

  CharacterSelectState copyWith({String? selectedCharacter}) =>
      CharacterSelectState(
          selectedCharacter: selectedCharacter ?? this.selectedCharacter);

  @override
  List<Object?> get props => [selectedCharacter];
}
