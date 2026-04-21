import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/score_repository.dart';
import '../../character_select/view/character_select_screen.dart';
import '../../score/view/score_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(context.read<ScoreRepository>())
        ..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '⚡ OVERWORK DODGE',
                  style: AppTextStyles.micro.copyWith(
                    color: AppColors.amber,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '야근 피하기',
                  style: AppTextStyles.heading.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/char_male_normal.png',
                          height: 120,
                          errorBuilder: (_, __, ___) =>
                              const Text('👨‍💼', style: TextStyle(fontSize: 60))),
                      const SizedBox(width: AppSpacing.md),
                      Image.asset('assets/images/char_female_normal.png',
                          height: 108,
                          errorBuilder: (_, __, ___) =>
                              const Text('👩‍💼', style: TextStyle(fontSize: 54))),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: state.bestScore > 0
                              ? AppColors.amber.withOpacity(0.3)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: AppSpacing.sm),
                          Text('최고 기록',
                              style: AppTextStyles.caption.copyWith(color: Colors.white60)),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            state.bestScore > 0
                                ? '${state.bestScore} s 생존'
                                : '기록 없음',
                            style: TextStyle(
                              color: state.bestScore > 0 ? AppColors.amber : Colors.white38,
                              fontSize: state.bestScore > 0 ? 22 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AppButton.primary(
                    label: '▶  게임 시작',
                    onPressed: () => _goCharacterSelect(context),
                    isFullWidth: true,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconBtn(context, '👤', '캐릭터',
                          () => _goCharacterSelect(context)),
                      const SizedBox(width: AppSpacing.xl),
                      _iconBtn(context, '🏆', '점수', () => _goScore(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goCharacterSelect(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CharacterSelectScreen()));
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeLoadRequested());
    }
  }

  Future<void> _goScore(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ScoreScreen()));
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeLoadRequested());
    }
  }

  Widget _iconBtn(BuildContext context, String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.micro.copyWith(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _background() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/game_background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),
        ],
      );
}
