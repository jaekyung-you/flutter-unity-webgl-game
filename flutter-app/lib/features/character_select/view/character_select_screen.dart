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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        color: Colors.white.withOpacity(0.6)),
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
                const Spacer(),
                Center(
                  child: Text(
                    '카드를 탭해서 선택하세요',
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.4)),
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
            color: isSelected ? AppColors.amber : Colors.white12,
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
                    color: Colors.white.withOpacity(0.5)),
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

  Widget _statBar(String label, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.micro.copyWith(color: Colors.white54)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white12,
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
