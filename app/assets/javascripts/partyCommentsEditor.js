/* global HDO */

(function (HDO) {
  HDO.partyCommentsEditor = {
    create: function (url) {
      var instance = Object.create(this);
      instance.url = url;
      return instance;
    },

    init: function (newRowHtml) {
      var self = this, count = 0;

      $('#new-comment-button').click(function () {
        var newId = 'new' + count++;
        $('#party-comments-table tr:last').after(newRowHtml.replace(/newPartyComment/g, newId));
        self.initializeMarkdownEditors([newId]);

        return false;
      });

      $('.destroy-comment').click(function () {
        $(this).closest('tr').remove();
        return false;
      });
    },

    initializeMarkdownEditors: function (partyCommentIds) {
      var i, converter, editor;
      for (i = 0; i < partyCommentIds.length; i++) {
        converter = new Markdown.Converter();
        editor = new Markdown.Editor(converter, "-" + partyCommentIds[i]);
        editor.run();
      }
    }
  };
}(HDO));
