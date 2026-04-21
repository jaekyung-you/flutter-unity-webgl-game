import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/repositories/score_repository.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

class GamePage extends StatelessWidget {
  final String character;

  const GamePage({super.key, this.character = 'male'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(context.read<ScoreRepository>()),
      child: _GameView(character: character),
    );
  }
}

class _GameView extends StatefulWidget {
  final String character;
  const _GameView({required this.character});

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  InAppWebViewController? _webController;
  InAppLocalhostServer? _localServer;
  bool _serverReady = false;

  static const int _port = 8080;
  static const String _indexUrl = 'http://localhost:$_port/index.html';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    _localServer = InAppLocalhostServer(port: _port, documentRoot: 'assets/unity/');
    await _localServer!.start();
    if (mounted) setState(() => _serverReady = true);
  }

  @override
  void dispose() {
    _localServer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_serverReady)
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_indexUrl)),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                transparentBackground: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
              ),
              onWebViewCreated: _onWebViewCreated,
              onConsoleMessage: (_, msg) => debugPrint('[Unity] ${msg.message}'),
            ),

          BlocBuilder<GameBloc, GameState>(
            builder: (context, state) => Stack(
              children: [
                if (state.isPlaying || state.isPaused) _buildHUD(context, state),
                if (state.isReady) _buildStartOverlay(context),
                if (state.isGameOver) _buildGameOverOverlay(context, state),
                if (state.status == GameStatus.loading) _buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webController = controller;
    final bloc = context.read<GameBloc>();

    controller.addJavaScriptHandler(
      handlerName: 'onUnityReady',
      callback: (_) => bloc.add(const GameUnityReady()),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onScoreUpdate',
      callback: (args) {
        if (args.isNotEmpty) bloc.add(GameScoreUpdated((args[0] as num).toInt()));
      },
    );
    controller.addJavaScriptHandler(
      handlerName: 'onBurnoutUpdate',
      callback: (args) {
        if (args.length >= 2) {
          bloc.add(GameBurnoutUpdated(
              (args[0] as num).toInt(), (args[1] as num).toInt()));
        }
      },
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDodgeUpdate',
      callback: (args) {
        if (args.isNotEmpty) bloc.add(GameDodgeUpdated((args[0] as num).toInt()));
      },
    );
    controller.addJavaScriptHandler(
      handlerName: 'onGameOver',
      callback: (args) {
        final finalScore = args.isNotEmpty ? (args[0] as num).toInt() : 0;
        final best = args.length > 1 ? (args[1] as num).toInt() : 0;
        bloc.add(GameOver(finalScore, best));
      },
    );
  }

  void _startGame(BuildContext context) {
    context.read<GameBloc>().add(const GameStarted());
    final charType = widget.character;
    _webController?.evaluateJavascript(source: 'window.flutterSetCharacter("$charType");');
    _webController?.evaluateJavascript(source: 'window.flutterStartGame();');
  }

  void _restartGame(BuildContext context) {
    context.read<GameBloc>().add(const GameRestarted());
    _webController?.evaluateJavascript(source: 'window.flutterRestartGame();');
  }

  void _togglePause(BuildContext context) {
    context.read<GameBloc>().add(const GamePauseToggled());
    _webController?.evaluateJavascript(source: 'window.flutterPause();');
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final wasPlaying = context.read<GameBloc>().state.isPlaying;
    if (wasPlaying) _togglePause(context);

    final confirmed = await AppDialog.show(
      context: context,
      title: '게임 중단',
      message: '게임을 중단하고 홈으로 나갈까요?',
      confirmLabel: '확인',
      cancelLabel: '취소',
      isDangerous: true,
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else if (wasPlaying) {
      _togglePause(context);
    }
  }

  Widget _buildHUD(BuildContext context, GameState state) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _hudCircleBtn('←', () => _showExitDialog(context)),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTimerWidget(state.score),
                  ],
                ),
                _hudCircleBtn(
                  state.isPaused ? '▶' : '⏸',
                  () => _togglePause(context),
                ),
                _buildDodgeBadge(state.dodgeCount),
              ],
            ),
          ),
          _buildBurnoutGauge(state.burnoutCurrent, state.burnoutMax),
          if (state.isPaused) _buildPauseOverlay(context),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moveButton('◄', 'left'),
                _moveButton('►', 'right'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.amber.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('⏸  일시정지',
                  style: AppTextStyles.title.copyWith(color: AppColors.amber)),
              const SizedBox(height: AppSpacing.sm),
              Text('계속하려면 ▶ 를 누르세요',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOverlay(BuildContext context) {
    return _overlay(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('칼퇴왕',
            style: AppTextStyles.display.copyWith(letterSpacing: 4)),
        const SizedBox(height: AppSpacing.sm),
        Text('← → 로 피하세요!',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.xl),
        AppButton.primary(
          label: '▶  START',
          onPressed: () => _startGame(context),
        ),
      ],
    ));
  }

  Widget _buildGameOverOverlay(BuildContext context, GameState state) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.danger.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GAME OVER',
                  style: AppTextStyles.heading.copyWith(
                      color: AppColors.danger,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: AppColors.danger.withOpacity(0.5), blurRadius: 10)
                      ])),
              const SizedBox(height: AppSpacing.xl),
              _scoreRow('생존 시간', '${state.score}초', Colors.white),
              const SizedBox(height: AppSpacing.sm),
              _scoreRow('회피 성공', '${state.dodgeCount}번', AppColors.success),
              const SizedBox(height: AppSpacing.sm),
              _scoreRow('최고 기록', '${state.bestScore}초', AppColors.amber),
              const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
              AppButton.primary(
                label: '다시 도전',
                onPressed: () => _restartGame(context),
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.ghost(
                label: '홈으로',
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.title.copyWith(color: valueColor)),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/game_background.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.6)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.amber),
              const SizedBox(height: AppSpacing.md),
              Text('출근 중...', style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerWidget(int seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.amber.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.amber.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.amber, size: 20),
          const SizedBox(width: 6),
          Text('$seconds',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900)),
          Text(' 초',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDodgeBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.success.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.success.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
          const SizedBox(width: 6),
          Text('$count',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildBurnoutGauge(int current, int max) {
    final double percentage = max > 0 ? current / max : 0;
    final Color barColor = percentage > 0.8
        ? AppColors.danger
        : percentage > 0.5
            ? AppColors.warning
            : AppColors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: barColor, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '스트레스',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 220,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm - 1),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 18,
                  ),
                  if (max > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        max - 1,
                        (index) => Container(
                            width: 1.5,
                            color: Colors.black.withOpacity(0.4)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moveButton(String label, String direction) {
    return _PressableMoveButton(
      label: label,
      onDown: () {
        if (direction == 'left') {
          _webController?.evaluateJavascript(source: 'window.flutterMoveLeft();');
        } else {
          _webController?.evaluateJavascript(source: 'window.flutterMoveRight();');
        }
      },
      onUp: () =>
          _webController?.evaluateJavascript(source: 'window.flutterStopMove();'),
    );
  }

  Widget _overlay(Widget child) =>
      Container(color: AppColors.surface0, child: Center(child: child));

  Widget _hudCircleBtn(String label, VoidCallback onTap) {
    return _PressableCircle(label: label, onTap: onTap);
  }
}

class _PressableCircle extends StatefulWidget {
  const _PressableCircle({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_PressableCircle> createState() => _PressableCircleState();
}

class _PressableMoveButton extends StatefulWidget {
  const _PressableMoveButton({
    required this.label,
    required this.onDown,
    required this.onUp,
  });
  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  State<_PressableMoveButton> createState() => _PressableMoveButtonState();
}

class _PressableMoveButtonState extends State<_PressableMoveButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        setState(() => _pressing = true);
        widget.onDown();
      },
      onPointerUp: (_) {
        setState(() => _pressing = false);
        widget.onUp();
      },
      onPointerCancel: (_) {
        setState(() => _pressing = false);
        widget.onUp();
      },
      child: AnimatedScale(
        scale: _pressing ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: Container(
          width: 96,
          height: 64,
          decoration: BoxDecoration(
            color: _pressing
                ? AppColors.amber.withOpacity(0.2)
                : AppColors.surface1,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: _pressing ? AppColors.amber.withOpacity(0.6) : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PressableCircleState extends State<_PressableCircle> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
