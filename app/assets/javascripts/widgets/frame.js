window.addEventListener('DOMContentLoaded', function () {
  if (!window.postMessage) {
    return;
  }

  var D, height, sizeMessage;

  D = document;
  height = Math.max(
    Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
    Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
    Math.max(D.body.clientHeight, D.documentElement.clientHeight)
  );

  sizeMessage = 'hdo-widget-size:' + height + 'px';

  // no sensitive data is being sent here, so * is fine.
  window.top.postMessage(sizeMessage, '*');
}, false);
