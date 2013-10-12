/* global HDO */

(function (HDO) {
  HDO.positionsEditor = {
    create: function (url) {
      var instance = Object.create(this);
      instance.url = url;
      return instance;
    },

    init: function (newRowHtml) {
      var self = this, count = 0;

      $('#new-position-button').click(function (e) {
        e.preventDefault();
        console.log(newRowHtml)

        var newId = 'new' + count++;

        $('#positions-table tr:last').after(newRowHtml.replace(/newPosition/g, newId));
        self.initializeMarkdownEditors([newId]);

        $('#position-' + newId + '-parties').chosen();

        $('#destroy-' + newId).click(function () {
          var row = $(this).closest('tr').remove();
          return false;
        });

        return false;
      });

      $('.destroy-position').click(function () {
        var id = $(this).attr('id').split('-')[1];
        $(this).closest('form').append($('<input/>')
          .attr('type', 'hidden')
          .attr('name', 'positions[' + id + '][deleted]')
          .val('true'));

        $(this).closest('tr').remove();

        return false;
      });
    },

    initializeMarkdownEditors: function (positionIds) {
      var i, converter, editor;
      for (i = 0; i < positionIds.length; i++) {
        converter = new Markdown.Converter();
        editor = new Markdown.Editor(converter, "-" + positionIds[i]);
        editor.run();

      }
    }
  };
}(HDO));
