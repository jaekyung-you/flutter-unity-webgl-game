import 'package:flutter/material.dart';
import '../models/game_record.dart';
import '../services/score_service.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<GameRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await ScoreService.getRecords();
    if (mounted) setState(() { _records = records; _loading = false; });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A4E),
        title: const Text('전체 삭제', style: TextStyle(color: Colors.white)),
        content: const Text('모든 기록을 삭제할까요?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ScoreService.clearAll();
      _load();
    }
  }

  GameRecord? get _best =>
      _records.isEmpty ? null : _records.reduce((a, b) => a.score > b.score ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      Expanded(
                        child: _records.isEmpty ? _empty() : _content(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            '내 기록',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (_records.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('전체 삭제', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📋', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('아직 플레이 기록이 없어요', style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(height: 4),
          Text('게임을 플레이하면 기록이 쌓입니다', style: TextStyle(color: Colors.white30, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _content() {
    final best = _best!;
    final totalPlays = _records.length;
    final avgScore = (_records.map((r) => r.score).reduce((a, b) => a + b) / totalPlays).round();
    final totalDodge = _records.map((r) => r.dodgeCount).reduce((a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best record hero card
          _bestCard(best),
          const SizedBox(height: 16),

          // Summary stats
          Row(
            children: [
              Expanded(child: _statCard('총 플레이', '$totalPlays회')),
              const SizedBox(width: 8),
              Expanded(child: _statCard('평균 생존', '${avgScore}s')),
              const SizedBox(width: 8),
              Expanded(child: _statCard('총 회피수', '$totalDodge')),
            ],
          ),
          const SizedBox(height: 20),

          // Recent records
          const Text(
            '최근 기록',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._records.map(_recordRow),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _bestCard(GameRecord best) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A6E), Color(0xFF1A1A50)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC00).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFCC00).withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('최고 기록', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${best.score}s 생존',
                  style: const TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(best.date)} · 회피 ${best.dodgeCount}회',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A4E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _recordRow(GameRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF15153A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(r.date),
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '회피 ${r.dodgeCount}회 · 번아웃 ${r.burnoutCount}회',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${r.score}s',
            style: const TextStyle(
              color: Color(0xFFFFCC00),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final hour = dt.hour;
    final ampm = hour < 12 ? '오전' : '오후';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}.${_p(dt.month)}.${_p(dt.day)} $ampm $h:$m';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  Widget _background() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1E), Color(0xFF151540)],
          ),
        ),
      );
}
