define(["jquery", "./ajax"], function ($, ajax) {

  var defaultOptions = {
      timeout: 10000,
      contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
    },
    log = function (str) {
      if (window.console) {
        console.log(str);
      }
    },
    globalErrorHandlers = {
      loginRequired: function () { log('loginRequired'); },
      accessDenied: function () { log('accessDenied'); },
      timeout: function () { log('timeout'); },
      error: function () { log('error'); }
    };

  function create(methods) {
    return $.extend(Object.create(this), methods);
  }

  function getOptions(url, params) {
    return $.extend({
      url: url,
      data: params
    }, this.getDefaultOptions());
  }

  function getCallbacks(callbacks) {
    return $.extend({}, globalErrorHandlers, callbacks);
  }

  function postJSON(url, params, callbacks) {
    var options = getOptions.call(this, url, params),
      cbs = getCallbacks.call(this, callbacks);

    ajax.postJSON(options, cbs);
  }

  function get(url, params, callbacks) {
    var options = getOptions.call(this, url, params),
      cbs = getCallbacks.call(this, callbacks);

    ajax.get(options, cbs);
  }

  function getDefaultOptions() {
    return $.extend({}, defaultOptions);
  }

  return {
    create: create,
    postJSON: postJSON,
    get: get,
    getDefaultOptions: getDefaultOptions
  };

});