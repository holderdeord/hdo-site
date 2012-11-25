var JZ = this.JZ || {};

(function ($) {

  var errorCodes = {
    400: 'accessDenied',
    500: 'internalServerError'
  };

  function handle(result, response, callbacks) {
    if (callbacks[result]) {
      callbacks[result](response);
    } else {
      callbacks.error();
    }
  }

  function successHandler(callbacks) {
    return function (response) {
      var result = !response ? 'timeout' : (response.result || 'success');
      handle(result, response, callbacks);
    };
  }

  function errorHandler(callbacks) {
    return function (xhr, status) {
      var result = status === 'timeout' ? status : errorCodes[xhr.status];
      handle(result, null, callbacks);
    };
  }

  function postJSON(options, callbacks) {
    var opts = $.extend({ type: 'POST', dataType: 'json' }, options);
    opts.success = successHandler(callbacks);
    opts.error = errorHandler(callbacks);
    $.ajax(opts);
  }

  function get(options, callbacks) {
    var opts = $.extend({ type: 'GET', dataType: 'html' }, options);
    opts.success = successHandler(callbacks);
    opts.error = errorHandler(callbacks);
    $.ajax(opts);
  }

  function getJSON(options, callbacks) {
    var opts = $.extend({ type: 'GET', dataType: 'json' }, options);
    opts.success = successHandler(callbacks);
    opts.error = errorHandler(callbacks);
    $.ajax(opts);
  }

  JZ.ajax = {
    postJSON: postJSON,
    get: get,
    getJSON: getJSON
  };

}(jQuery));
