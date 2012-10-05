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

  function filterByParty(self) {
    var result = $(self.targetEl).find("div[data-party-slug]").get();
    result.forEach(filterResults, self);
    return false;
  }

  function partyClicked(ev) {
    var partySlug = getSlugname(ev),
      partyElement = $(ev.currentTarget).parent().get(0);

    setActiveParty(this, partySlug, partyElement);
    filterByParty(this);
    return false;
  }

  function renderAndFilterResults(data) {
    this.targetEl.html(data);
    var result = $(this.targetEl).find("div").get();
    result.forEach(filterResults, this);
  }

  function categoryClicked(ev) {
    setActiveCategory(this, ev.currentTarget);
    var categoryId = $(this.activeCategory).data("category-id");
    this.server.fetchPromises(categoryId, renderAndFilterResults.bind(this));

    return false;
  }

  HDO.promiseWidget = {
    create: function (params) {
      var instance = Object.create(this);
      instance.server = params.server;
      instance.categoriesSelector = params.categoriesSelector;
      instance.activeParty = params.activeParty;
      instance.targetEl = params.targetEl;
      instance.partiesSelector = params.partiesSelector;
      return instance;
    },

    init: function () {
      $(this.categoriesSelector).on("click", "a[data-category-id]", categoryClicked.bind(this));
      $(this.partiesSelector).on("click", "a[data-party-slug]", partyClicked.bind(this));
    }
  }

}(HDO, jQuery));


