import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/repositories/score_repository.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../controller/unity_bridge.dart';
import 'widgets/game_hud.dart';
import 'widgets/game_over_overlay.dart';
import 'widgets/loading_overlay.dart';
import 'widgets/start_overlay.dart';

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
  final _bridge = UnityBridge();
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
    try {
      _localServer = InAppLocalhostServer(port: _port, documentRoot: 'assets/unity/');
      await _localServer!.start();
      if (mounted) setState(() => _serverReady = true);
    } catch (_) {
      await _localServer?.close();
      _localServer = InAppLocalhostServer(port: _port, documentRoot: 'assets/unity/');
      await _localServer!.start();
      if (mounted) setState(() => _serverReady = true);
    }
  }

  @override
  void dispose() {
    _localServer?.close();
    super.dispose();
  }

  void _startGame() {
    context.read<GameBloc>().add(const GameStarted());
    _bridge.startGame(widget.character);
  }

  void _restartGame() {
    context.read<GameBloc>().add(const GameRestarted());
    _bridge.restartGame();
  }

  void _togglePause() {
    context.read<GameBloc>().add(const GamePauseToggled());
    _bridge.togglePause();
  }

  Future<void> _showExitDialog() async {
    final wasPlaying = context.read<GameBloc>().state.isPlaying;
    if (wasPlaying) _togglePause();

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
      _togglePause();
    }
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
              onWebViewCreated: (controller) =>
                  _bridge.attach(controller, context.read<GameBloc>()),
              onConsoleMessage: (_, msg) => debugPrint('[Unity] ${msg.message}'),
            ),
          BlocBuilder<GameBloc, GameState>(
            builder: (context, state) => Stack(
              children: [
                if (state.isPlaying || state.isPaused)
                  GameHud(
                    state: state,
                    onExit: _showExitDialog,
                    onTogglePause: _togglePause,
                    onMoveLeftDown: _bridge.moveLeft,
                    onMoveLeftUp: _bridge.stopMove,
                    onMoveRightDown: _bridge.moveRight,
                    onMoveRightUp: _bridge.stopMove,
                  ),
                if (state.isReady) StartOverlay(onStart: _startGame),
                if (state.isGameOver)
                  GameOverOverlay(
                    state: state,
                    onRestart: _restartGame,
                    onHome: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                if (state.status == GameStatus.loading)
                  const LoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
