/*global HDO */

(function (H) {
  HDO.issueEditor = {
    create: function (selector) {
      var instance = Object.create(this);
      instance.root = $(selector);
      return instance;
    }

    , init: function() {
        HDO.markdownEditor();

        this.saveButton            = this.root.find('button[name=save]');
        this.editorSelect          = this.root.find('select#issue_editor');
        this.categorySelect        = this.root.find('select#issue_categories');
        this.positionPartySelects  = this.root.find('select.position-parties');
        this.newPositionButton     = this.root.find('#new-position');
        this.newPartyCommentButton = this.root.find('#new-party-comment');
        this.tagList               = this.root.find('input[name=tags]');
        this.expandables           = this.root.find('[data-expands]');

        this.saveButton.click(this.save.bind(this));
        this.newPositionButton.click(this.notImplemented.bind(this));
        this.newPartyCommentButton.click(this.notImplemented.bind(this));
        this.expandables.click(this.toggleRow.bind(this));

        this.editorSelect.chosen();
        this.categorySelect.chosen();
        this.positionPartySelects.chosen();

        this.setupTagList();
        this.setupTemplates();
      }

    , save: function(e) {
        e.preventDefault();
        this.toggleSpin();

        // simulate xhr
        setTimeout(function() {
          this.toggleSpin();
        }.bind(this), 3000)
      }

    , toggleSpin: function() {
        this.root.find('.accordion-group').toggle();
        this.root.find('.spinner').toggleClass('hidden');
      }

    , data: function() {
        return this.root.parent('form').serializeArray();
      }

    , setupTagList: function() {
        var el = this.tagList;
        el.tagsManager({
          prefilled: el.data('current-tags').split(","),
          preventSubmitOnEnter: true,
          typeahead: true,
          typeaheadSource: el.data('all-tags').split(","),
          hiddenTagListName: 'issue[tag_list]'
        });
      }

    , setupTemplates: function() {
        var templates, templateSources;

        this.templateSources = templateSources = {
          promiseConnection: this.root.find('#promise-connection-template').html()
        };

        this.templates = templates = {};

        templates.fetch = function(name) {
          templates[name] = templates[name] || Handlebars.compile(this.templateSources[name])
          return templates[name];
        }.bind(this);
      }

    , toggleRow: function(e) {
      var el = $(e.delegateTarget);
      el.find('.expandable, .expanded').toggleClass('expandable expanded');
      $(el.data('expands')).slideToggle();
    }

    , notImplemented: function(e) {
      e.preventDefault();
      alert('ikke enda');
    }

    , newPromiseConnectionHtmlFor: function(promise) {
        return this.templates.fetch('promiseConnection')(promise)
      }
  };
}(HDO));
