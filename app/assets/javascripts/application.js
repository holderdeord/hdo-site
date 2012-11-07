// JavaScript should now be defined using AMD-syntax:
// http://addyosmani.com/writing-modular-js/
//
// RequireJS docs: http://requirejs.org/docs/api.html
//
// Without AMD:
// var myModule = (function ($) {
//   return {...};
// })(jQuery);
//
// With AMD the file-name is the name of the module, so define it anonymously:
// myModule.js:
// define(["jQuery"], function ($) {
//   return {...};
// });
//
// You can depend on scripts using the assets-pipeline name, and add a shim config in requirejs.yml
// if it is not using AMD. jQuery-plugins typically don't have to use exports. See requirejs docs
// for more info about shims: http://requirejs.org/docs/api.html#config-shim
// shim:
//   "highcharts":
//     deps:
//       - "jquery"
//     exports:  "Highcharts"
//
// This is the main script for requirejs on every page of the site. Inline script has been replaced
// with re-usable widgets. In development mode the widgets and dependencies will be loaded async on
// demand, but for production the new widgets have to be added to bundle.js manually.
//
// A widget is an HTML-element that we want to enrich with JavaScript functionality. Instead of
// having an inline script initializing it, add a data-widget attribute with the widget module
// as value. (widget/ is prefixed to enforce all widgets is placed there)
//
// <div data-widget="myWidget"></div>
//
// application.js will look for any elements with a data-widget attribute and require the module.
// For the example above, it will load app/assets/javascript/widgets/myWidget.js
//
// Since a widget should be re-usable, it should not hard-code what elements to attach to. Instead
// it should return a function that takes an element as first argument, and initialize the widget
// on this element. Ideally a widget is just a thin layer to bind other modules to HTML-elements.
//
// define(["jquery", "hdo/myModule"], function ($, myModule) {
//    return function (element) {
//      myModule.init(element);
//    };
// });
//
// Sometimes you need to pass dynamic data to the widgets. Preferably the widget/module should
// load this through ajax instead, but it can also use a named define (bad practise):
// define("myData", function () {
//   <%= @myData.to_json.html_safe %>;
// });
//
// The widget/module have to require the data on demand to avoid compilation errors when building
// the production bundle.
//
// var myData = require("myData"); // notice no array => sync require instead of async
//
/*global require: true*/
require(["require", "jquery"], function (require, $) {
  $("[data-widget]").each(function (i, container) {
    var widgetName = "widgets/" + this.getAttribute("data-widget");
    require([widgetName], function (widget) {
      if (widget && typeof widget === "function") {
        widget(container);
      }
    });
  });
});
