var HDO = HDO || {};

(function (H, $) {

  function setActiveCategory(self, targetElement) {
    if (self.activeCategory) {
      $(self.activeCategory).removeClass("active");
    }
    self.activeCategory = targetElement;
    $(self.activeCategory).addClass("active");
  }

  function setActiveParty(self, slug, partyElement) {
    var className = slug + "-active";
    if (self.activeParty) {
      $(self.activeParty).removeClass();
    }
    self.activeParty = partyElement;
    $(self.activeParty).addClass(className);
  }

  function getSlugname(ev) {
    return $(ev.currentTarget).data("party-slug");
  }

  function showEmptyResultsMessage(self) {
    self.targetEl.find('#empty-results-message').html('<h3>Partiet har ingen løfter i denne kategorien.</h3>')
      .removeClass('hidden');
  }

  function filterResults(ev, index, el) {
    var lastSelectedSlug = $(this.activeParty).find("a").data("party-slug"),
      selectedSlug = $(ev).data("party-slug"),
      element = $(el[index]).get(0);

    if (selectedSlug === lastSelectedSlug || lastSelectedSlug === 'show-all') {
      $(element).removeClass("hidden");
    } else {
      $(element).addClass("hidden");
    }
  }

  function filterResultsForMobile(ev, index, el) {
    var selectedSlug = $(this.partiesSelector).find('option:selected').data('party-slug'),
      element = $(el[index]).get(0);

    if ($(element).data('party-slug') === selectedSlug || selectedSlug === 'show-all') {
      $(element).removeClass("hidden");
    } else {
      $(element).addClass("hidden");
    }

  }

  function filterByParty(self, ev) {
    $('#empty-results-message').html('');
    var result = $(self.targetEl).find("div[data-party-slug]").get();

    if (ev.type === 'change') {
      result.forEach(filterResultsForMobile, self);
    } else {
      result.forEach(filterResults, self);
    }

    if (self.targetEl.find('div').not('.hidden').length === 2) {
      showEmptyResultsMessage(self);
    }
    return false;
  }

  function partyClicked(ev) {
    var partySlug, partyElement;

    if (ev.type === 'change') {
      partySlug = $(ev.srcElement).find(':selected').data('a[party-slug]');
      partyElement = $(ev.srcElement).find(':selected').get(0);
    } else {
      partySlug = getSlugname(ev);
      partyElement = $(ev.currentTarget).parent().get(0);
    }
    setActiveParty(this, partySlug, partyElement);
    filterByParty(this, ev);

    return false;
  }

  function renderAndFilterResults(data) {
    this.targetEl.html(data);
    this.targetEl.append('<div id=empty-results-message></div>');
    var result = $(this.targetEl).find("div").get();
    result.forEach(filterResults, this);
  }

  function renderAndFilterResultsForMobile(data) {
    this.targetEl.css('padding-left', '0px');
    this.targetEl.html(data);
    this.targetEl.append('<div id=empty-results-message></div>');
    var result = $(this.targetEl).find("div").get();
    result.forEach(filterResultsForMobile, this);
  }

  function fillSubcategorySelector(categories) {
    var self = this,
      categoriesObject = $.parseJSON(categories),
      i;

    $(self.getSubCategories).empty();

    for (i = 0; i < categoriesObject.length; i++) {
      $(self.subCategoriesSelector).append('<option data-category-id=' +
        categoriesObject[i].id + '>' + categoriesObject[i].name + '</option>');
    }

  }

  function categoryClicked(ev) {
    var categoryId;

    if (ev.type === 'change') {
      categoryId = $(ev.srcElement).find(':selected').data('category-id');
      this.server.getSubCategories(categoryId, fillSubcategorySelector.bind(this));

      this.subCategoriesSelector.removeClass('hidden');
      this.server.fetchPromises(categoryId, renderAndFilterResultsForMobile.bind(this));
    } else {
      setActiveCategory(this, ev.currentTarget);
      categoryId = $(this.activeCategory).data("category-id");
      this.server.fetchPromises(categoryId, renderAndFilterResults.bind(this));
    }

    return false;
  }

  function subCategoryClicked(ev) {
    var categoryId = $(ev.srcElement).find(':selected').data('category-id');
    this.server.fetchPromises(categoryId, renderAndFilterResultsForMobile.bind(this));
  }

  HDO.promiseWidget = {
    create: function (params) {
      var instance = Object.create(this);
      instance.server = params.server;
      instance.categoriesSelector = params.categoriesSelector;
      instance.activeParty = params.activeParty;
      instance.targetEl = params.targetEl;
      instance.partiesSelector = params.partiesSelector;
      instance.subCategoriesSelector = params.subCategoriesSelector;
      return instance;
    },

    init: function () {
      $(this.categoriesSelector).on("click", "a[data-category-id]", categoryClicked.bind(this));
      $(this.categoriesSelector).on("change", categoryClicked.bind(this));
      $(this.partiesSelector).on("click", "a[data-party-slug]", partyClicked.bind(this));
      $(this.partiesSelector).on("change", partyClicked.bind(this));
      $(this.subCategoriesSelector).on("change", subCategoryClicked.bind(this));

    }
  };

}(HDO, jQuery));


