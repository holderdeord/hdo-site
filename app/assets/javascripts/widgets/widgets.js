//= require ../lib/object.create

var HDO = HDO || {};

(function (H, D, W) {
  H.widgets = {
    counter: 0,
    baseUrl: '',

    load: function (baseUrl) {
      this.baseUrl = baseUrl;
      this.on('message', this.resize);

      H.widgets.create('representative').init();
      H.widgets.create('issue').init();
      H.widgets.create('topic').init();
      H.widgets.create('promises').init();
      H.widgets.create('party').init();
    },

    resize: function (event) {
      var data, action, height, iframes, style, i, l;

      data   = event.data.split(':');
      action = data[0];
      height = data[1];

      if (action !== 'hdo-widget-size') {
        return;
      }

      iframes = D.getElementsByTagName('iframe');

      for (i = 0, l = iframes.length; i < l; i++) {
        if (iframes[i].contentWindow === event.source) {
          style           = iframes[i].style;
          style.height    = data[1];
          style.maxHeight = data[1];

          return;
        }
      }
    },

    on: function (eventName, callback) {
      if (W.addEventListener) { // W3C DOM
        W.addEventListener(eventName, callback, false);
      } else if (W.attachEvent) { // IE DOM
        W.attachEvent('on' + eventName, callback);
      }
    },

    create: function (type) {
      var instance = Object.create(this);
      instance.type = type;
      return instance;
    },

    createWidgetFrame: function (opts) {
      var iframe = D.createElement('iframe');

      H.widgets.counter++;

      iframe.id          = "hdo-widget-" + H.widgets.counter;
      iframe.src         = opts.url;
      iframe.width       = '100%';
      iframe.frameBorder = 0;
      iframe.scrolling   = 'no';
      iframe.title       = 'holderdeord.no widget';

      return iframe;
    },

    queryParamFor: function (key, value) {
      return key + '=' + encodeURIComponent(value);
    },

    addIssueParams: function (el, url) {
      var issues, count;

      issues = el.getAttribute('data-issue-ids');
      count  = el.getAttribute('data-issue-count');

      if (issues && issues.length) {
        url += '?' + this.queryParamFor('issues', issues);
      } else if (count && count.length) {
        url += '?' + this.queryParamFor('count', count);
      }

      return url;
    },

    promisesQueryFor: function (str) {
      if (!(window.JSON && window.JSON.parse)) {
        return '';
      }

      var data, result, key, val, i;

      data = JSON.parse(str);
      result = [];

      for (key in data) {
        if (data.hasOwnProperty(key)) {
          result.push('promises[' + key + ']=' + encodeURIComponent(data[key].join(',')));
        }
      }

      return result.join('&');
    },

    widgetOptionsFor: function (el) {
      var url, target;

      if (this.type === "issue") {
        url = H.widgets.baseUrl + "issues/" + el.getAttribute('data-issue-id') + '/widget';
      } else if (this.type === "representative") {
        url = H.widgets.baseUrl + "representatives/" + el.getAttribute('data-representative-id') + '/widget';
        url = this.addIssueParams(el, url);
      } else if (this.type === "party") {
        url = H.widgets.baseUrl + "parties/" + el.getAttribute('data-party-id') + '/widget';
        url = this.addIssueParams(el, url);
      } else if (this.type === "topic") {
        url = H.widgets.baseUrl + "widgets/topic?" + this.queryParamFor('issues', el.getAttribute('data-issues')) + '&'
                                                   + this.promisesQueryFor(el.getAttribute('data-promises'));
      } else if (this.type === "promises") {
        url = H.widgets.baseUrl + "promises/" + encodeURIComponent(el.getAttribute('data-promises')) + "/widget";
      } else {
        throw new Error('invalid HDO widget type: ' + this.type);
      }

      target = el.getAttribute('data-target');

      if (target && target.length) {
        if (url.indexOf('?') > 0) {
          url += '&' + this.queryParamFor('target', target);
        } else {
          url += '?' + this.queryParamFor('target', target);
        }
      }

      return { 'url': url };
    },

    findWidgetElements: function () {
      var elements, nodes, widgetClass, i, l;

      elements    = [];
      widgetClass = 'hdo-' + this.type + '-widget';

      if (D.getElementsByClassName) {
        nodes = D.getElementsByClassName(widgetClass);

        // avoid the live NodeList, since we'll replace nodes
        for (i = 0, l = nodes.length; i < l; i++) {
          elements.push(nodes[i]);
        }
      } else if (D.querySelectorAll) {
        elements = D.querySelectorAll('.' + widgetClass);
      } else {
        nodes = D.getElementsByTagName('*');

        for (i = 0, l = nodes.length; i < l; i++) {
          if (nodes[i].className === widgetClass) {
            elements.push(nodes[i]);
          }
        }
      }

      return elements;
    },


    init: function () {
      var elements, element, iframe, i, l;

      elements = this.findWidgetElements();

      for (i = 0, l = elements.length; i < l; i++) {
        element = elements[i];
        iframe = this.createWidgetFrame(this.widgetOptionsFor(element));

        element.parentNode.replaceChild(iframe, element);
      }
    }

  };
}(HDO, document, window));
