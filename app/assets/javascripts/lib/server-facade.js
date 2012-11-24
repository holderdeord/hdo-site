var JZ = this.JZ || {};

(function ($) {

  var defaultOptions = {
    timeout: 10000,
    contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
  };

  var globalErrorHandlers = {
    loginRequired: function () { console && console.log('loginRequired'); },
    accessDenied: function () { console && console.log('accessDenied'); },
    timeout: function () { console && console.log('timeout'); },
    error: function () { console && console.log('error'); }
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
    var options = getOptions.call(this, url, params);
    var cbs = getCallbacks.call(this, callbacks);
    JZ.ajax.postJSON(options, cbs);
  }

  function get(url, params, callbacks) {
    var options = getOptions.call(this, url, params);
    var cbs = getCallbacks.call(this, callbacks);
    JZ.ajax.get(options, cbs);
  }

  function getJSON(url, params, callbacks) {
    var options = getOptions.call(this, url, params);
    var cbs = getCallbacks.call(this, callbacks);
    JZ.ajax.getJSON(options, cbs);
  }

  function getDefaultOptions() {
    return $.extend({}, defaultOptions);
  }

  JZ.serverFacade = {
    create: create,
    postJSON: postJSON,
    get: get,
    getJSON: getJSON,
    getDefaultOptions: getDefaultOptions
  };

}(jQuery));