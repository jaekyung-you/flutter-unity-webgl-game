import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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
                      child: CircularProgressIndicator(color: AppColors.amber));
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Text('←',
                style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary)),
          ),
          Text('내 기록', style: AppTextStyles.title),
          const Spacer(),
          if (state.records.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: Text('전체 삭제',
                  style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
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
        backgroundColor: AppColors.dialogSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: AppColors.danger.withOpacity(0.5), width: 1.5),
        ),
        title: Text('전체 삭제',
            style: AppTextStyles.title.copyWith(color: AppColors.amber)),
        content: Text('모든 기록을 삭제할까요?',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        actions: [
          AppButton.ghost(label: '취소', onPressed: () => Navigator.pop(context, false)),
          AppButton.danger(label: '삭제', onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirm == true) bloc.add(const ScoreClearRequested());
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.sm),
          Text('아직 플레이 기록이 없어요',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xs),
          Text('게임을 플레이하면 기록이 쌓입니다',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bestCard(best),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _statCard('총 플레이', '$totalPlays회')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _statCard('평균 생존', '${avgScore}s')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _statCard('총 회피수', '$totalDodge')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('최근 기록',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          ...records.map(_recordRow),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _bestCard(GameRecord best) {
    return AppCard(
      highlighted: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('최고 기록',
                    style: AppTextStyles.micro.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.xs),
                Text('${best.score}s 생존',
                    style: AppTextStyles.heading.copyWith(color: AppColors.amber)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                    '${_formatDate(best.date)} · 회피 ${best.dodgeCount}회',
                    style: AppTextStyles.micro.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.title.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.micro),
        ],
      ),
    );
  }

  Widget _recordRow(GameRecord r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(r.date),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('회피 ${r.dodgeCount}회 · 번아웃 ${r.burnoutCount}회',
                    style: AppTextStyles.micro),
              ],
            ),
          ),
          Text('${r.score}s',
              style: AppTextStyles.title.copyWith(color: AppColors.amber)),
        ],
      ),
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

  Widget _background() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/game_background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.45)),
        ],
      );
}
