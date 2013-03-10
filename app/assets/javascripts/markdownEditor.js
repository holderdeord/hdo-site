/* global HDO */

(function (HDO) {
  HDO.markdownEditor = function() {
    $("[data-wmd-editor]").each(function() {
      var converter = new Markdown.Converter();
      var editor = new Markdown.Editor(converter, "-" + $(this).data('wmd-editor'));

      editor.run();
    });
  };
}(HDO));
