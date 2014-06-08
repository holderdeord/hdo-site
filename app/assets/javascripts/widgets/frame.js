(function () {
    if (!window.postMessage || window.self === window.top) {
        return;
    }

    function reportWidgetSize() {
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
    }

    if (window.addEventListener) { // W3C DOM
        window.addEventListener('load', reportWidgetSize, false);
        window.addEventListener('resize', reportWidgetSize, false);
    } else if (window.attachEvent) { // IE DOM
        window.attachEvent('onload', reportWidgetSize);
        window.attachEvent('resize', reportWidgetSize);
    }
}());
