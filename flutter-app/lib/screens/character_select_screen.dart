import 'package:flutter/material.dart';
import '../services/score_service.dart';
import '../game_page.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  String _selected = 'male';

  @override
  void initState() {
    super.initState();
    ScoreService.getSelectedCharacter().then((c) {
      if (mounted) setState(() => _selected = c);
    });
  }

  Future<void> _startGame() async {
    await ScoreService.saveSelectedCharacter(_selected);
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => GamePage(character: _selected)),
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),

          // Moon (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: _moon(90),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '캐릭터 선택',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

                // Character cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _characterCard('male', '신입사원 남자', '패기 넘치는 새내기', '체력이 좋음', 0.75, 0.40)),
                      const SizedBox(width: 12),
                      Expanded(child: _characterCard('female', '신입사원 여자', '눈치 빠른 멀티태스커', '회피력이 높음', 0.55, 0.80)),
                    ],
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

                // Start button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startGame,
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
                        '▶  이 캐릭터로 시작',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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

  Widget _characterCard(String id, String name, String desc, String trait,
      double speedRatio, double burnoutRatio) {
    final isSelected = _selected == id;
    return GestureDetector(
      onTap: () => setState(() => _selected = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCC00) : Colors.white12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFFFFCC00).withOpacity(0.25), blurRadius: 16)]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Checkmark
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFCC00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 14),
                ),
              ),
            ),

            // Character image
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

            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              trait,
              style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Stat bars
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
              blurRadius: 40,
              spreadRadius: 6,
            ),
          ],
        ),
      );
}
