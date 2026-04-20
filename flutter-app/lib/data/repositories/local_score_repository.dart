import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_record.dart';
import 'score_repository.dart';

class LocalScoreRepository implements ScoreRepository {
  static const _recordsKey = 'game_records';
  static const _characterKey = 'selected_character';

  @override
  Future<List<GameRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recordsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final records = list
        .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  @override
  Future<void> addRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.insert(0, record);
    await prefs.setString(
        _recordsKey, jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }

  @override
  Future<int> getBestScore() async {
    final records = await getRecords();
    if (records.isEmpty) return 0;
    return records.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<String> getSelectedCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_characterKey) ?? 'male';
  }

  @override
  Future<void> saveSelectedCharacter(String character) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_characterKey, character);
  }
}
