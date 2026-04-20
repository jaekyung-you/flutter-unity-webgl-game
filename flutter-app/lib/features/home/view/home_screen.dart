import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            right: 28,
            child: _moon(110),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _cityscape(context),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '⚡ OVERWORK DODGE',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '야근 피하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
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
                      const SizedBox(width: 16),
                      Image.asset('assets/images/char_female_normal.png',
                          height: 108,
                          errorBuilder: (_, __, ___) =>
                              const Text('👩‍💼', style: TextStyle(fontSize: 54))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          const Text('최고 기록',
                              style: TextStyle(color: Colors.white60, fontSize: 14)),
                          const SizedBox(width: 16),
                          Text(
                            state.bestScore > 0
                                ? '${state.bestScore} s 생존'
                                : '기록 없음',
                            style: TextStyle(
                              color: state.bestScore > 0
                                  ? AppColors.yellow
                                  : Colors.white38,
                              fontSize: state.bestScore > 0 ? 22 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goCharacterSelect(context),
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
                        '▶  게임 시작',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconBtn(context, '👤', '캐릭터',
                          () => _goCharacterSelect(context)),
                      const SizedBox(width: 32),
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
          color: AppColors.cardDark,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
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
              blurRadius: 48,
              spreadRadius: 8,
            ),
          ],
        ),
      );

  Widget _cityscape(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 100,
      child: CustomPaint(painter: _CityscapePainter(), size: Size(w, 100)),
    );
  }
}

class _CityscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0A28);
    final buildings = [
      [0.0, 0.55, 0.12, 1.0],
      [0.10, 0.3, 0.08, 1.0],
      [0.16, 0.5, 0.10, 1.0],
      [0.25, 0.2, 0.07, 1.0],
      [0.30, 0.4, 0.09, 1.0],
      [0.38, 0.25, 0.06, 1.0],
      [0.43, 0.55, 0.11, 1.0],
      [0.53, 0.35, 0.08, 1.0],
      [0.60, 0.15, 0.07, 1.0],
      [0.66, 0.45, 0.10, 1.0],
      [0.75, 0.3, 0.08, 1.0],
      [0.82, 0.5, 0.09, 1.0],
      [0.90, 0.4, 0.10, 1.0],
    ];
    for (final b in buildings) {
      canvas.drawRect(
        Rect.fromLTRB(b[0] * size.width, b[1] * size.height,
            (b[0] + b[2]) * size.width, b[3] * size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
