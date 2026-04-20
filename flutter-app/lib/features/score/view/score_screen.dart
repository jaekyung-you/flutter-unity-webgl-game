import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_record.dart';
import '../../../data/repositories/score_repository.dart';
import '../bloc/score_bloc.dart';
import '../bloc/score_event.dart';
import '../bloc/score_state.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScoreBloc(context.read<ScoreRepository>())
        ..add(const ScoreLoadRequested()),
      child: const _ScoreView(),
    );
  }
}

class _ScoreView extends StatelessWidget {
  const _ScoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: BlocBuilder<ScoreBloc, ScoreState>(
              builder: (context, state) {
                if (state.status == ScoreStatus.loading) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.yellow));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, state),
                    Expanded(
                        child: state.records.isEmpty
                            ? _empty()
                            : _content(state.records)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, ScoreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text('내 기록',
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (state.records.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: const Text('전체 삭제',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<ScoreBloc>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('전체 삭제', style: TextStyle(color: Colors.white)),
        content: const Text('모든 기록을 삭제할까요?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) bloc.add(const ScoreClearRequested());
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('📋', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('아직 플레이 기록이 없어요',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
          SizedBox(height: 4),
          Text('게임을 플레이하면 기록이 쌓입니다',
              style: TextStyle(color: Colors.white30, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _content(List<GameRecord> records) {
    final best = records.reduce((a, b) => a.score > b.score ? a : b);
    final totalPlays = records.length;
    final avgScore =
        (records.map((r) => r.score).reduce((a, b) => a + b) / totalPlays).round();
    final totalDodge = records.map((r) => r.dodgeCount).reduce((a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bestCard(best),
          const SizedBox(height: 16),
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
          const Text('최근 기록',
              style: TextStyle(
                  color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...records.map(_recordRow),
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
        border: Border.all(color: AppColors.yellow.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: AppColors.yellow.withOpacity(0.1), blurRadius: 20),
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
                const Text('최고 기록',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${best.score}s 생존',
                    style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                    '${_formatDate(best.date)} · 회피 ${best.dodgeCount}회',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
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
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _recordRow(GameRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDarker,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(r.date),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('회피 ${r.dodgeCount}회 · 번아웃 ${r.burnoutCount}회',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text('${r.score}s',
              style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
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
            colors: [AppColors.background, AppColors.backgroundEnd],
          ),
        ),
      );
}
