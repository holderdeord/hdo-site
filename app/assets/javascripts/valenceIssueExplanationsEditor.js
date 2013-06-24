/* global HDO */

(function (HDO) {
  HDO.valenceIssueExplanationsEditor = {
    create: function (url) {
      var instance = Object.create(this);
      instance.url = url;
      return instance;
    },

    init: function (newRowHtml) {
      var self = this, count = 0;

      $('#new-explanation-button').click(function () {
        var newId = 'new' + count++;
        $('#explanations-table tr:last').after(newRowHtml.replace(/newExplanation/g, newId));
        self.initializeMarkdownEditors([newId]);

        $('#explanation-' + newId + '-parties').chosen();

        $('#destroy-' + newId).click(function () {
          var row = $(this).closest('tr').remove();

          return false;
        });

        return false;
      });

      $('.destroy-explanation').click(function () {
        var id = $(this).attr('id').split('-')[1];
        $(this).closest('form').append($('<input/>')
          .attr('type', 'hidden')
          .attr('name', 'valence_issue_explanations[' + id + '][deleted]')
          .val('true'));

        $(this).closest('tr').remove();

        return false;
      });
    },

    initializeMarkdownEditors: function (explanationIds) {
      var i, converter, editor;
      for (i = 0; i < explanationIds.length; i++) {
        converter = new Markdown.Converter();
        editor = new Markdown.Editor(converter, "-" + explanationIds[i]);
        editor.run();

      }
    }
  };
}(HDO));
