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
      this.promiseSearchElement  = this.root.find('#promise-search-tab');
      this.propositionSearchElement  = this.root.find('#proposition-search-tab');

      this.saveButton.click(this.save.bind(this));
      this.newPositionButton.click(this.notImplemented.bind(this));
      this.newPartyCommentButton.click(this.notImplemented.bind(this));
      this.expandables.click(this.toggleRow.bind(this));
      this.promiseSearchElement.delegate('.navigators a', 'click', this.filterPromises.bind(this));
      this.propositionSearchElement.delegate('.navigators a', 'click', this.filterPropositions.bind(this));

      this.editorSelect.chosen();
      this.categorySelect.chosen();
      this.positionPartySelects.chosen();

      this.setupTagList();
      this.setupTemplates();

      this.renderPromiseSearch();
      this.renderPropositionSearch();
    },

    save: function (e) {
      e.preventDefault();
      this.toggleSpin();

      // simulate xhr
      setTimeout(function () {
        this.toggleSpin();
      }.bind(this), 3000);
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

    renderPromiseSearch: function (url) {
      var template, el, promiseSpinner;

      url = url || '/promises';
      template = this.templates['promise-search-template'];
      el = this.promiseSearchElement;
      promiseSpinner = $('#promise-spinner');

      promiseSpinner.toggleClass('hidden');

      $.ajax({
        url: url,
        dataType: 'json',
        success: function (data) { el.html(template(data)); },
        error: function (xhr) { window.alert('Uffda, noe gikk helt galt ' + xhr.status); },
        complete: function () { promiseSpinner.toggleClass('hidden'); }
      });
    },

    renderPropositionSearch: function (url) {
      var template, el, propositionSpinner;

      url = url || '/propositions';
      template = this.templates['proposition-search-template'];
      el = this.propositionSearchElement;

      propositionSpinner = $('#proposition-spinner');
      propositionSpinner.toggleClass('hidden');

      $.ajax({
        url: url,
        dataType: 'json',
        success: function (data) { el.html(template(data)); },
        error: function (xhr) { window.alert('Uffda, noe gikk helt galt ' + xhr.status); },
        complete: function () { propositionSpinner.toggleClass('hidden'); }
      });
    },

    filterPromises: function (e) {
      e.preventDefault();
      this.renderPromiseSearch(e.target.href);
    },

    filterPropositions: function (e) {
      e.preventDefault();
      this.renderPropositionSearch(e.target.href);
    }

  };
}(jQuery, HDO, Handlebars));
