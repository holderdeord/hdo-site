/*global HDO, jQuery, Markdown */

/*

 To use this, provide the following markup:

 <div data-wmd-editor="1">
   <div id="wmd-button-bar-1" />
   <textarea id="wmd-input-1">
   <div id="wmd-preview-1" />
 </div>

 The data-wmd-editor attribute should unique for the page,
 and can be any valid attribute string.

 */

(function (HDO, $, Markdown) {
    HDO.markdownEditor = function (opts) {
        var options = $.extend({
            root: document.body
        }, opts);

        $(options.root).find('[data-wmd-editor]').each(function () {
            var converter, editor, suffix;

            suffix = '-' + $(this).data('wmd-editor');
            converter = new Markdown.Converter();
            editor = new Markdown.Editor(converter, suffix);

            editor.run();
        });
    };
}(HDO, jQuery, Markdown));
