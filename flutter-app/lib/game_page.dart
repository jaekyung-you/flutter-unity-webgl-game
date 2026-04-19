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
  int _score = 0;
  int _bestScore = 0;

  static const int _port = 8080;

  // documentRoot 'assets/unity/' → URL /index.html → rootBundle key 'assets/unity/index.html'
  // URL /Build/WebGL.loader.js → rootBundle key 'assets/unity/Build/WebGL.loader.js'
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
          // WebView only after server is ready to avoid hitting a dead socket
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

          // Score overlay
          if (_gameStarted && !_gameOver)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Start overlay
          if (_unityReady && !_gameStarted)
            _overlay(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TAP RUNNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '화면을 탭하면 점프!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  _button('START', Colors.blue, _startGame),
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
                    'Score: $_score',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    'Best: $_bestScore',
                    style: const TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  const SizedBox(height: 28),
                  _button('RESTART', Colors.orange, _restartGame),
                ],
              ),
            ),

          // Loading overlay (server starting or Unity loading)
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
                      'Loading Unity...',
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

  Widget _overlay(Widget child) =>
      Container(color: Colors.black54, child: Center(child: child));

  Widget _button(String label, Color color, VoidCallback onTap) {
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
      handlerName: 'onGameOver',
      callback: (args) {
        final int finalScore = args.isNotEmpty ? (args[0] as num).toInt() : _score;
        final int best = args.length > 1 ? (args[1] as num).toInt() : _bestScore;
        setState(() {
          _gameOver = true;
          _score = finalScore;
          _bestScore = best;
        });
      },
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _score = 0;
    });
    _webController?.evaluateJavascript(source: 'window.flutterStartGame();');
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _score = 0;
    });
    _webController?.evaluateJavascript(source: 'window.flutterRestartGame();');
  }
}
