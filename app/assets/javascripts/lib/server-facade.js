var JZ = this.JZ || {};

(function ($) {

  var defaultOptions = {
    timeout: console && console.log('timeout'),
    contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
  };
  
  var globalErrorHandlers = {
    loginRequired: function () { alert('loginRequired'); },
    accessDenied: function () { alert('accessDenied'); },
    timeout: function () { alert('timeout'); },
    error: function () { alert('error'); }
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

  function getDefaultOptions() {
    return $.extend({}, defaultOptions);
  }
  
  JZ.serverFacade = {
    create: create,
    postJSON: postJSON,
    get: get,
    getDefaultOptions: getDefaultOptions
  };
  
}(jQuery));