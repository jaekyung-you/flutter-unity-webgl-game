import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  InAppWebViewController? _webController;
  InAppLocalhostServer? _localServer;

  bool _serverReady = false;
  bool _unityReady = false;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _isPaused = false;
  int _score = 0;
  int _bestScore = 0;
  int _burnoutCurrent = 0;
  int _burnoutMax = 5;
  int _dodgeCount = 0;

  static const int _port = 8080;
  static const String _indexUrl = 'http://localhost:$_port/index.html';

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    _localServer = InAppLocalhostServer(
      port: _port,
      documentRoot: 'assets/unity/',
    );
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
              onConsoleMessage: (controller, msg) {
                debugPrint('[Unity] ${msg.message}');
              },
            ),

          // HUD: shown during active gameplay
          if (_gameStarted && !_gameOver)
            _buildHUD(),

          // Start overlay
          if (_unityReady && !_gameStarted)
            _overlay(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '칼퇴왕',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '← → 로 피하세요!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  _actionButton('START', Colors.blue, _startGame),
                ],
              ),
            ),

          // Game Over overlay
          if (_gameOver)
            _overlay(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '생존: $_score초',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    '회피: $_dodgeCount개',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    '최고: $_bestScore초',
                    style: const TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  const SizedBox(height: 28),
                  _actionButton('다시 도전', Colors.orange, _restartGame),
                ],
              ),
            ),

          // Loading overlay
          if (!_unityReady)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      '출근 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar: timer | pause | dodge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hudChip('⏱ $_score초'),
                GestureDetector(
                  onTap: _togglePause,
                  child: _hudChip(_isPaused ? '▶' : '⏸'),
                ),
                _hudChip('✅ $_dodgeCount'),
              ],
            ),
          ),

          // Burnout gauge (directly below top bar, no hardcoded offset)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_burnoutMax, (i) {
                final filled = i < _burnoutCurrent;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 24,
                      color: filled ? Colors.orange : Colors.white24,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Middle: transparent spacer (Unity canvas visible underneath)
          const Spacer(),

          // Bottom ◄ ► buttons
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

  Widget _hudChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
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
      onPointerUp: (_) {
        _webController?.evaluateJavascript(source: 'window.flutterStopMove();');
      },
      onPointerCancel: (_) {
        _webController?.evaluateJavascript(source: 'window.flutterStopMove();');
      },
      child: Container(
        width: 96,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlay(Widget child) =>
      Container(color: Colors.black54, child: Center(child: child));

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webController = controller;

    controller.addJavaScriptHandler(
      handlerName: 'onUnityReady',
      callback: (_) => setState(() => _unityReady = true),
    );

    controller.addJavaScriptHandler(
      handlerName: 'onScoreUpdate',
      callback: (args) {
        if (args.isNotEmpty) {
          setState(() => _score = (args[0] as num).toInt());
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'onBurnoutUpdate',
      callback: (args) {
        if (args.length >= 2) {
          setState(() {
            _burnoutCurrent = (args[0] as num).toInt();
            _burnoutMax = (args[1] as num).toInt();
          });
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'onDodgeUpdate',
      callback: (args) {
        if (args.isNotEmpty) {
          setState(() => _dodgeCount = (args[0] as num).toInt());
        }
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'onGameOver',
      callback: (args) {
        final int finalScore = args.isNotEmpty ? (args[0] as num).toInt() : _score;
        final int best = args.length > 1 ? (args[1] as num).toInt() : _bestScore;
        setState(() {
          _gameOver = true;
          _score = finalScore;
          _bestScore = best;
          _isPaused = false;
        });
      },
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
      _burnoutCurrent = 0;
      _dodgeCount = 0;
      _isPaused = false;
    });
    _webController?.evaluateJavascript(source: 'window.flutterStartGame();');
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _score = 0;
      _burnoutCurrent = 0;
      _dodgeCount = 0;
      _isPaused = false;
    });
    _webController?.evaluateJavascript(source: 'window.flutterRestartGame();');
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    _webController?.evaluateJavascript(source: 'window.flutterPause();');
  }
}
