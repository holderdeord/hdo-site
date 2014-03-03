/*global jQuery, HDO, Handlebars */

(function ($, HDO, Handlebars) {
  HDO.issueEditor = {
    create: function (selector, url) {
      var instance = Object.create(this);
      instance.root = $(selector);
      instance.url = url;
      return instance;
    },

    init: function () {
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

      this.facetSearch({
        baseUrl:  '/promises',
        root:     this.root.find('#promise-search-tab'),
        spinner:  $("#promise-spinner"),
        template: this.templates['promise-search-template']
      });

      this.facetSearch({
        baseUrl:  '/propositions',
        root:     this.root.find('#proposition-search-tab'),
        spinner:  $("#proposition-spinner"),
        template: this.templates['proposition-search-template']
      });
    },

    save: function (e) {
      e.preventDefault();
      this.toggleSpin();

      // simulate xhr
      setTimeout(function () {
        this.toggleSpin();
      }.bind(this), 1000);
    },

    toggleSpin: function () {
      this.root.find('.accordion-group').toggle();
      $('#spinner').toggle();
    },

    data: function () {
      return this.root.parent('form').serializeArray();
    },

    setupTagList: function () {
      var el = this.tagList;
      el.tagsManager({
        prefilled: el.data('current-tags').split(","),
        preventSubmitOnEnter: true,
        typeahead: true,
        typeaheadSource: el.data('all-tags').split(","),
        hiddenTagListName: 'issue[tag_list]'
      });
    },

    setupTemplates: function () {
      var templates;
      this.templates = templates = {};

      $("script[type='text/x-handlebars-template']").each(function () {
        var el, name, partialName;

        el = $(this);
        name = el.attr('name');
        partialName = name.match(/^(\w+?)-partial$/);
        partialName = partialName && partialName[1];

        if (partialName) {
          Handlebars.registerPartial(partialName, el.html());
        } else {
          templates[name] = Handlebars.compile(el.html());
        }
      });
    },

    toggleRow: function (e) {
      var el = $(e.delegateTarget);
      el.find('.expandable, .expanded').toggleClass('expandable expanded');
      $(el.data('expands')).slideToggle();
    },

    notImplemented: function (e) {
      e.preventDefault();
      window.alert('ikke enda');
    },

    newPromiseConnectionHtmlFor: function (promise) {
      return this.templates['promise-connection-template'](promise);
    },

    facetSearch: function (opts) {
      var baseUrl, root, template, spinner, query;

      baseUrl  = opts.baseUrl;
      root     = opts.root;
      template = opts.template;
      spinner  = opts.spinner || $("#spinner");
      query    = opts.root.find('input[name=q]');

      function render(url) {
        spinner.toggleClass('hidden');

        $.ajax({
          url: url || baseUrl,
          dataType: 'json',
          success: function (data) { root.html(template(data)); },
          error: function (xhr) { window.alert('Uffda, noe gikk helt galt ' + xhr.status); },
          complete: function () { spinner.toggleClass('hidden'); }
        });
      }

      function filterHandler(e) {
        e.preventDefault();
        render(e.target.href);
      }

      function queryHandler(e) {
        if (e.which === 13) {
          e.preventDefault();

          var target = $(this),
            url = decodeURI(target.data('url-template'));

          url = url.replace('{query}', encodeURIComponent(target.val()));
          render(url);
        }
      }

      function toggleResult(e) {
        $(this).toggleClass('selected');
      }

      root.delegate('.navigators a, a[data-xhr]', 'click', filterHandler);
      root.delegate('input[name=q]', 'keypress', queryHandler);
      root.delegate('.search-result', 'click', toggleResult);

      render();
    }

  };
}(jQuery, HDO, Handlebars));
