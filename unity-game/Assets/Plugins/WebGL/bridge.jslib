mergeInto(LibraryManager.library, {

  // Unity → Flutter: 점수 전송
  SendScoreToFlutter: function(score) {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('onScoreUpdate', score);
    }
  },

  // Unity → Flutter: 게임 오버 전송
  SendGameOverToFlutter: function(finalScore, bestScore) {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('onGameOver', finalScore, bestScore);
    }
  },

});
