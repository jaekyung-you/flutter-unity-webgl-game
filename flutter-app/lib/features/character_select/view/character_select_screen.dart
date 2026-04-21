import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/score_repository.dart';
import '../../game/view/game_page.dart';
import '../bloc/character_select_bloc.dart';
import '../bloc/character_select_event.dart';
import '../bloc/character_select_state.dart';

class CharacterSelectScreen extends StatelessWidget {
  const CharacterSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CharacterSelectBloc(context.read<ScoreRepository>())
        ..add(const CharacterSelectLoadRequested()),
      child: const _CharacterSelectView(),
    );
  }
}

class _CharacterSelectView extends StatelessWidget {
  const _CharacterSelectView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Text('←',
                            style: AppTextStyles.title.copyWith(
                                color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('캐릭터 선택', style: AppTextStyles.title),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    '함께 야근을 피할 동료를 골라요',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BlocBuilder<CharacterSelectBloc, CharacterSelectState>(
                  builder: (context, state) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                            child: _characterCard(context, state, 'male',
                                '신입사원 남자', '패기 넘치는 새내기', '체력이 좋음', 0.75, 0.40)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: _characterCard(context, state, 'female',
                                '신입사원 여자', '눈치 빠른 멀티태스커', '회피력이 높음', 0.55, 0.80)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ 피해야 할 것들',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _obstacleList(),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    '카드를 탭해서 선택하세요',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: AppButton.primary(
                    label: '▶  이 캐릭터로 시작',
                    onPressed: () => _startGame(context),
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startGame(BuildContext context) async {
    final bloc = context.read<CharacterSelectBloc>();
    bloc.add(const CharacterConfirmed());
    final character = bloc.state.selectedCharacter;
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => GamePage(character: character)));
  }

  Widget _characterCard(BuildContext context, CharacterSelectState state, String id,
      String name, String desc, String trait, double speedRatio, double burnoutRatio) {
    final isSelected = state.selectedCharacter == id;
    return GestureDetector(
      onTap: () =>
          context.read<CharacterSelectBloc>().add(CharacterChanged(id)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardDeep,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.amber : AppColors.divider,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: AppColors.amber.withOpacity(0.25), blurRadius: 16)]
              : [],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                      color: AppColors.amber, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.black, size: 14),
                ),
              ),
            ),
            SizedBox(
              height: 110,
              child: Image.asset(
                'assets/images/char_${id}_normal.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  id == 'male' ? '👨‍💼' : '👩‍💼',
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(name,
                style: AppTextStyles.caption.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(desc,
                style: AppTextStyles.micro.copyWith(
                    color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(trait,
                style: AppTextStyles.micro.copyWith(
                    color: AppColors.amber, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            _statBar('이동속도', speedRatio),
            const SizedBox(height: 6),
            _statBar('번아웃 저항', burnoutRatio),
          ],
        ),
      ),
    );
  }

  static const _obstacles = [
    ('document_pile', '서류더미'),
    ('kpi_bomb', 'KPI 폭탄'),
    ('meeting_mail', '회의 메일'),
    ('overtime_notice', '야근 통보'),
    ('overwork_coffee', '야근 커피'),
    ('revision_laptop', '수정 요청'),
    ('urgent_phone', '긴급 전화'),
  ];

  Widget _obstacleList() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _obstacles.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final (id, label) = _obstacles[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/$id.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 24),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.micro
                      .copyWith(color: AppColors.textMuted, fontSize: 9)),
            ],
          );
        },
      ),
    );
  }

  Widget _statBar(String label, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _background() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/game_background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
        ],
      );
}
