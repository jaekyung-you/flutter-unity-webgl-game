import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class UnityBridge {
  InAppWebViewController? _controller;

  void attach(InAppWebViewController controller, GameBloc bloc) {
    _controller = controller;

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
        bloc.add(GameOver(finalScore));
      },
    );
  }

  void startGame(String character) {
    _controller?.evaluateJavascript(
        source: 'window.flutterSetCharacter("$character");');
    _controller?.evaluateJavascript(source: 'window.flutterStartGame();');
  }

  void restartGame() {
    _controller?.evaluateJavascript(source: 'window.flutterRestartGame();');
  }

  void togglePause() {
    _controller?.evaluateJavascript(source: 'window.flutterPause();');
  }

  void moveLeft() {
    _controller?.evaluateJavascript(source: 'window.flutterMoveLeft();');
  }

  void moveRight() {
    _controller?.evaluateJavascript(source: 'window.flutterMoveRight();');
  }

  void stopMove() {
    _controller?.evaluateJavascript(source: 'window.flutterStopMove();');
  }
}
