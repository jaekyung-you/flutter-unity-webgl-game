import 'package:equatable/equatable.dart';
import '../../../data/models/game_record.dart';

enum ScoreStatus { loading, loaded }

class ScoreState extends Equatable {
  final ScoreStatus status;
  final List<GameRecord> records;

  const ScoreState({this.status = ScoreStatus.loading, this.records = const []});

  ScoreState copyWith({ScoreStatus? status, List<GameRecord>? records}) =>
      ScoreState(
          status: status ?? this.status,
          records: records ?? this.records);

  @override
  List<Object?> get props => [status, records];
}
