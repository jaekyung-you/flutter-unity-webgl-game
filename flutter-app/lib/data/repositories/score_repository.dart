import '../models/game_record.dart';

abstract class ScoreRepository {
  Future<List<GameRecord>> getRecords();
  Future<void> addRecord(GameRecord record);
  Future<void> clearAll();
  Future<int> getBestScore();
  Future<String> getSelectedCharacter();
  Future<void> saveSelectedCharacter(String character);
}
