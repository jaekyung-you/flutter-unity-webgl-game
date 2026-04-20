import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: _moon(90),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text('캐릭터 선택',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '함께 야근을 피할 동료를 골라요',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 28),
                BlocBuilder<CharacterSelectBloc, CharacterSelectState>(
                  builder: (context, state) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: _characterCard(context, state, 'male',
                                '신입사원 남자', '패기 넘치는 새내기', '체력이 좋음', 0.75, 0.40)),
                        const SizedBox(width: 12),
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
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startGame(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 8,
                        shadowColor: AppColors.yellow.withOpacity(0.5),
                      ),
                      child: const Text(
                        '▶  이 캐릭터로 시작',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.yellow : Colors.white12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: AppColors.yellow.withOpacity(0.25), blurRadius: 16)]
              : [],
        ),
        padding: const EdgeInsets.all(16),
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
                      color: AppColors.yellow, shape: BoxShape.circle),
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
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(desc,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(trait,
                style: const TextStyle(
                    color: AppColors.yellow, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
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
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _background() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.backgroundMid,
              AppColors.backgroundEnd,
            ],
          ),
        ),
      );

  Widget _moon(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFE566),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFE566).withOpacity(0.4),
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
        ),
      );
}
