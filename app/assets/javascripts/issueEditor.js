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
      this.setupTemplates();
      this.renderForm();

      HDO.markdownEditor();

      this.form                  = $('form.edit_issue');
      this.saveButton            = this.root.find('button[name=save]');
      this.editorSelect          = this.root.find('select#issue_editor_id');
      this.categorySelect        = this.root.find('select#issue_category_ids');
      this.positionPartySelects  = this.root.find('select.position-parties');
      this.newPositionButton     = this.root.find('#new-position');
      this.newPartyCommentButton = this.root.find('#new-party-comment');
      this.tagList               = this.root.find('input[name=tags]');
      this.promiseSearchTab      = this.root.find('#promise-search-tab');
      this.promiseSpinner        = this.root.find("#promise-spinner");
      this.propositionConnectTab = this.root.find("#proposition-connections-tab");
      this.propositionSearchTab  = this.root.find('#proposition-search-tab');
      this.propositionSpinner    = this.root.find("#proposition-spinner");
      this.errorElement          = this.root.find('.error-message');

      this.saveButton.click(this.save.bind(this));
      this.newPositionButton.click(this.newPosition.bind(this));
      this.newPartyCommentButton.click(this.notImplemented.bind(this));
      this.root.delegate('[data-expands]', 'click', this.toggleRow.bind(this));

      this.editorSelect.chosen();
      this.categorySelect.chosen();
      this.positionPartySelects.chosen();
      this.root.find('.position-form').hide();

      this.setupTagList();
      this.setupCarts();

      this.facetSearch({
        baseUrl:  '/promises',
        root:     this.promiseSearchTab,
        spinner:  this.promiseSpinner,
        template: this.templates['promise-search-template'],
        cart:     this.promiseCart
      });

      this.facetSearch({
        baseUrl:  '/propositions',
        root:     this.propositionSearchTab,
        spinner:  this.propositionSpinner,
        template: this.templates['proposition-search-template'],
        cart:     this.propositionCart
      });
    },

    save: function (e) {
      e.preventDefault();
      this.toggleSpin();

      var self = this;

      $.ajax({
        url: this.url,
        method: 'POST',
        data: this.form.serialize(),
        success: function (data) {
          window.location.href = data.location; // trololol
        },
        error: function (xhr) {
          self.toggleSpin();
          self.errorElement.html(xhr.responseText).show();
        }
      });
    },

    toggleSpin: function () {
      this.root.find('.accordion-group').toggle();
      $('#spinner').toggle();
    },

    newPosition: function (e) {
      var position, created, template;

      e.preventDefault();

      position = { id: 0, party_ids: [], priority: 0 };
      template = this.templates['position-template'];

      created = $(template(position)).prependTo('.positions');
      created.addClass('new');
      created.find('.expandable, .expanded').toggleClass('expandable expanded');

      created.find('.position-parties').chosen();
      HDO.markdownEditor({root: created});
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
        name = el.data('name');
        partialName = name.match(/^(\w+?)-partial$/);
        partialName = partialName && partialName[1];

        if (partialName) {
          Handlebars.registerPartial(partialName, el.html());
        } else {
          templates[name] = Handlebars.compile(el.html());
        }
      });

      Handlebars.registerHelper('selectedIfEqual', function (a, b) {
        return a === b && 'selected';
      });

      Handlebars.registerHelper('selectedIfInclude', function (a, b) {
        if (b.indexOf(a) !== -1) {
          return 'selected';
        }
      });
    },

    // TODO: get rid of all the duplication
    setupCarts: function () {
      var toggleRow, promiseTemplate, propositionTemplate;

      this.promiseCart = this.createCart($('.cart[data-type=promises]'));
      this.propositionCart = this.createCart($('.cart[data-type=propositions]'));

      toggleRow = this.toggleRow;
      promiseTemplate = this.templates['promise-connection-template'];
      propositionTemplate = this.templates['proposition-connection-template'];

      this.promiseCart.on('use', function (items) {
        if (items.length === 0) {
          return;
        }

        $('a[href=#promise-connections-tab]').click();

        $.ajax({
          url: '/admin/issues/promises/' + items.join(','),
          dataType: 'json',
          success: function (data) {
            $.each(data, function () {
              var created = $(promiseTemplate(this)).prependTo('#promise-connections-tab');
              created.addClass('new');
            });
          },
          error: function (xhr) {
            window.alert('Uffda, noe gikk helt galt ' + xhr.status);
          },
          complete: function () {
            // TODO: spinner
          }
        });
      });

      this.propositionCart.on('use', function (items) {
        if (items.length === 0) {
          return;
        }

        $('a[href=#proposition-connections-tab]').click();

        $.ajax({
          url: '/admin/issues/propositions/' + items.join(','),
          dataType: 'json',
          success: function (data) {
            $.each(data, function () {
              var created = $(propositionTemplate(this)).prependTo('#proposition-connections-tab');
              created.addClass('new');
              HDO.markdownEditor({root: created});
            });
          },
          error: function (xhr) {
            window.alert('Uffda, noe gikk helt galt ' + xhr.status);
          },
          complete: function () {
            // TODO: spinner
          }
        });
      });
    },

    toggleRow: function (e) {
      var el = $(e.target).parents('.row-fluid:first');
      el.find('.expandable, .expanded').toggleClass('expandable expanded');
      $(el.data('expands')).slideToggle();
    },

    notImplemented: function (e) {
      e.preventDefault();
      window.alert('ikke enda');
    },

    renderForm: function () {
      function render(template, i, e) {
        var el = $(e);
        el.html(template(el.data('context')));
      }

      $(".proposition-connection").each(render.bind(null, this.templates['proposition-connection-template']));
      $(".promise-connection").each(render.bind(null, this.templates['promise-connection-template']));
      $(".position").each(render.bind(null, this.templates['position-template']));
    },

    facetSearch: function (opts) {
      var baseUrl, root, template, spinner, query, cart;

      baseUrl  = opts.baseUrl;
      root     = opts.root;
      template = opts.template;
      spinner  = opts.spinner || $("#spinner");
      query    = opts.root.find('input[name=q]');
      cart     = opts.cart;

      function prepareData(data) {
        $.each(data.results, function (i, e) {
          e.selected = cart.isSelected(Number(e.id));
        });

        return data;
      }

      function render(url) {
        spinner.toggleClass('hidden');

        $.ajax({
          url: url || baseUrl,
          dataType: 'json',
          success: function (data) { root.html(template(prepareData(data))); },
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
        var el = $(this), id;

        id = el.data('id');
        el.toggleClass('selected');

        if (el.hasClass('selected')) {
          cart.add(id);
        } else {
          cart.remove(id);
        }
      }

      cart.on('clear', function () {
        root.find('.search-result.selected').removeClass('selected');
      });

      root.delegate('.navigators a, a[data-xhr]', 'click', filterHandler);
      root.delegate('input[name=q]', 'keypress', queryHandler);
      root.delegate('.search-result', 'click', toggleResult);

      render();
    },

    createCart: function (el) {
      var items, template, callbacks;

      items = [];
      template = this.templates['shopping-cart-template'];
      callbacks = {clear: [], use: []};

      function invokeCallbacks(type) {
        $(callbacks[type]).each(function (i, cb) {
          cb(items);
        });
      }

      function render() {
        el.html(template({items: items}));
      }

      function isSelected(id) {
        return items.indexOf(id) !== -1;
      }

      function add(id) {
        items.push(id);
        render();
      }

      function remove(id) {
        var idx = items.indexOf(id);
        if (idx > -1) {
          items.splice(idx, 1);
          render();
        }
      }

      function clear() {
        items = [];
        invokeCallbacks('clear');
        render();
      }

      function use() {
        invokeCallbacks('use');
        clear();
      }

      function addCallback(type, cb) {
        if (typeof cb !== 'function') {
          throw new TypeError('expected function, got ' + typeof cb);
        }

        if (Object.keys(callbacks).indexOf(type) === -1) {
          throw new Error('invalid callback type ' + type);
        }

        callbacks[type].push(cb);
      }

      el.delegate('a[data-action=use]', 'click', function (e) {
        e.preventDefault();
        use();
      });

      el.delegate('a[data-action=clear]', 'click', function (e) {
        e.preventDefault();
        clear();
      });

      render();

      return {
        isSelected: isSelected,
        add: add,
        remove: remove,
        on: addCallback
      };
    }

  };
}(jQuery, HDO, Handlebars));
