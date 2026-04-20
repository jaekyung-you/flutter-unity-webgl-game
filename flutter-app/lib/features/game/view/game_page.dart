import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/constants/app_colors.dart';
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

  Widget _buildHUD(BuildContext context, GameState state) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hudChip('⏱ ${state.score}초'),
                GestureDetector(
                  onTap: () => _togglePause(context),
                  child: _hudChip(state.isPaused ? '▶' : '⏸'),
                ),
                _hudChip('✅ ${state.dodgeCount}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(state.burnoutMax, (i) {
                final filled = i < state.burnoutCurrent;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text('🔥',
                      style: TextStyle(
                          fontSize: 24,
                          color: filled ? Colors.orange : Colors.white24)),
                );
              }),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

  Widget _buildStartOverlay(BuildContext context) {
    return _overlay(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('칼퇴왕',
            style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 8),
        const Text('← → 로 피하세요!',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 32),
        _actionButton('START', AppColors.yellow, () => _startGame(context),
            textColor: Colors.black),
      ],
    ));
  }

  Widget _buildGameOverOverlay(BuildContext context, GameState state) {
    return _overlay(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('GAME OVER',
            style: TextStyle(
                color: Colors.red, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('생존: ${state.score}초',
            style: const TextStyle(color: Colors.white, fontSize: 24)),
        Text('회피: ${state.dodgeCount}개',
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
        Text('최고: ${state.bestScore}초',
            style: const TextStyle(color: AppColors.yellow, fontSize: 20)),
        const SizedBox(height: 28),
        _actionButton('다시 도전', Colors.orange, () => _restartGame(context)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const Text('홈으로',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      ],
    ));
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.yellow),
            SizedBox(height: 16),
            Text('출근 중...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _hudChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _moveButton(String label, String direction) {
    return Listener(
      onPointerDown: (_) {
        if (direction == 'left') {
          _webController?.evaluateJavascript(source: 'window.flutterMoveLeft();');
        } else {
          _webController?.evaluateJavascript(source: 'window.flutterMoveRight();');
        }
      },
      onPointerUp: (_) =>
          _webController?.evaluateJavascript(source: 'window.flutterStopMove();'),
      onPointerCancel: (_) =>
          _webController?.evaluateJavascript(source: 'window.flutterStopMove();'),
      child: Container(
        width: 96,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _overlay(Widget child) =>
      Container(color: Colors.black54, child: Center(child: child));

  Widget _actionButton(String label, Color color, VoidCallback onTap,
      {Color textColor = Colors.white}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: TextStyle(fontSize: 22, color: textColor)),
    );
  }
}
