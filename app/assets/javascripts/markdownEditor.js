/*global HDO, jQuery, Markdown */

(function (HDO, $, Markdown) {
  HDO.markdownEditor = function (opts) {
    var options = $.extend({
      root: document.body
    }, opts)

    $(options.root).find("[data-wmd-editor]").each(function () {
      var converter, editor;

      converter = new Markdown.Converter();
      editor = new Markdown.Editor(converter, "-" + $(this).data('wmd-editor'));

      editor.run();
    });
  };
}(HDO, jQuery, Markdown));
