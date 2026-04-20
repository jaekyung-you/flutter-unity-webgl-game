mergeInto(LibraryManager.library, {

  SendScoreToFlutter: function(score) {
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onScoreUpdate', score);
  },

  SendGameOverToFlutter: function(finalScore, bestScore) {
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onGameOver', finalScore, bestScore);
  },

  SendBurnoutToFlutter: function(current, max) {
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onBurnoutUpdate', current, max);
  },

  SendDodgeToFlutter: function(count) {
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onDodgeUpdate', count);
  },

});
