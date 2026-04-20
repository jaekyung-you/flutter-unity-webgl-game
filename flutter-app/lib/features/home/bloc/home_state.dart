import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int bestScore;

  const HomeState({this.bestScore = 0});

  HomeState copyWith({int? bestScore}) =>
      HomeState(bestScore: bestScore ?? this.bestScore);

  @override
  List<Object?> get props => [bestScore];
}
