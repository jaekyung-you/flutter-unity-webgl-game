import 'package:flutter/material.dart';
import '../services/score_service.dart';
import 'character_select_screen.dart';
import 'score_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final best = await ScoreService.getBestScore();
    if (mounted) setState(() => _bestScore = best);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _background(),

          // Moon
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            right: 28,
            child: _moon(110),
          ),

          // City silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _cityscape(context),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Title
                const Text(
                  '⚡ OVERWORK DODGE',
                  style: TextStyle(
                    color: Color(0xFFFFCC00),
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

                // Character illustrations
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset('assets/images/char_male_normal.png',
                          height: 120, errorBuilder: (_, __, ___) => const Text('👨‍💼', style: TextStyle(fontSize: 60))),
                      const SizedBox(width: 16),
                      Image.asset('assets/images/char_female_normal.png',
                          height: 108, errorBuilder: (_, __, ___) => const Text('👩‍💼', style: TextStyle(fontSize: 54))),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Best score card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A4E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        const Text(
                          '최고 기록',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _bestScore > 0 ? '$_bestScore s 생존' : '기록 없음',
                          style: TextStyle(
                            color: _bestScore > 0 ? const Color(0xFFFFCC00) : Colors.white38,
                            fontSize: _bestScore > 0 ? 22 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Start button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CharacterSelectScreen()),
                        );
                        if (result == true) _loadBestScore();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF0A0A1E),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFFCC00).withOpacity(0.5),
                      ),
                      child: const Text(
                        '▶  게임 시작',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom icon buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconBtn('👤', '캐릭터', () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CharacterSelectScreen()));
                      }),
                      const SizedBox(width: 32),
                      _iconBtn('🏆', '점수', () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ScoreScreen()));
                        _loadBestScore();
                      }),
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

  Widget _iconBtn(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A4E),
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
            colors: [Color(0xFF0A0A1E), Color(0xFF0D1040), Color(0xFF151540)],
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
      final rect = Rect.fromLTRB(
        b[0] * size.width,
        b[1] * size.height,
        (b[0] + b[2]) * size.width,
        b[3] * size.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
