//= require ../lib/object.create
//= require ../conditional/json2

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

            iframe.id          = 'hdo-widget-' + H.widgets.counter;
            iframe.src         = opts.url;
            iframe.width       = '100%';
            iframe.frameBorder = 0;
            iframe.scrolling   = 'no';
            iframe.title       = 'holderdeord.no widget';

            return iframe;
        },

        parseOrNull: function (str) {
            if (!(window.JSON && window.JSON.parse)) {
                return null;
            } else {
                return JSON.parse(str);
            }
        },

        widgetOptionsFor: function (el) {
            var path = '', params = {};


            if (this.type === 'issue') {
                path           = 'issues/:issueId/widget';
                params.issueId = el.getAttribute('data-issue-id');
                params.period  = el.getAttribute('data-period');
            } else if (this.type === 'representative') {
                path                    = 'representatives/:representativeId/widget';
                params.representativeId = el.getAttribute('data-representative-id');
                params.issues           = el.getAttribute('data-issue-ids');
                params.count            = el.getAttribute('data-issue-count');
            } else if (this.type === 'party') {
                path           = 'parties/:partyId/widget';
                params.partyId = el.getAttribute('data-party-id');
                params.count   = el.getAttribute('data-count');
                params.issues  = el.getAttribute('data-issue-ids');
            } else if (this.type === 'topic') {
                path            = 'widgets/topic';
                params.issues   = el.getAttribute('data-issues');
                params.promises = this.parseOrNull(el.getAttribute('data-promises'));
            } else if (this.type === 'promises') {
                path            = 'promises/:promises/widget';
                params.promises = el.getAttribute('data-promises');
            } else {
                throw new Error('invalid HDO widget type: ' + this.type);
            }

            var target = el.getAttribute('data-target');

            if (target && target.length) {
                params.target = target;
            }

            var partner = el.getAttribute('data-partner');

            if (partner && partner.length) {
                params.partner = partner;
            }

            return { 'url': this.buildUrl(H.widgets.baseUrl + path, params) };
        },

        buildUrl: function (url, params) {
            var key;

            for (key in params) {
                if (params.hasOwnProperty(key)) {
                    url = this.addParam(url, key, params[key]);
                }
            }

            return url;
        },

        addParam: function (url, key, value) {
            if (!value) {
                return url;
            }

            if (value === Object(value)) {
                var result = [];
                for (var k in value) {
                    if (value.hasOwnProperty(k)) {
                        result.push(key + '[' + k + ']=' + encodeURIComponent(value[k]));
                    }
                }

                url += url.indexOf('?') < 0 ? '?' : '&';
                url += result.join('&');
            } else if (value.length) {
                var exp = new RegExp(':' + key, 'g');
                if (url.match(exp)) {
                    url = url.replace(exp, encodeURIComponent(value));
                } else {
                    url += url.indexOf('?') < 0 ? '?' : '&';
                    url += key + '=' + encodeURIComponent(value);
                }
            }

            return url;
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
