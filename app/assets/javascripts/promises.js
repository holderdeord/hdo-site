var HDO = HDO || {};

(function (H, $) {

  function setActiveCategory(self, ev) {
    if (self.activeCategory) {
      $(self.activeCategory).removeClass("active");
    }
    self.activeCategory = ev.currentTarget;
    $(self.activeCategory).addClass("active");
  }

  function setActiveParty(self, ev, slug) {
    var className = slug + "-active";
    if (self.activeParty) {
      $(self.activeParty).removeClass();
    }
    self.activeParty = $(ev.currentTarget).parent().get(0);
    $(self.activeParty).addClass(className);
  }

  function insertPromisesInTarget(data) {
    this.targetEl.innerHTML = data;
  }

  function fetchPromises(ev) {
    setActiveCategory(this, ev);
    var categoryId = $(this.activeCategory).data("category-id");
    this.server.fetchPromises(categoryId, insertPromisesInTarget.bind(this));

    return false;
  }

  function getSlugname(ev) {
    return $(ev.currentTarget).data("party-slug");
  }

  function filterByParty(ev) {
    var activePartySlug = getSlugname(ev);
    var result = $(this.targetEl).find("div[data-party-slug]").get();

    var filterParties = function (el) {
        if ($(el).data("party-slug") === activePartySlug || activePartySlug === 'show-all') {
          $(el).removeClass("hidden");
        } else {
          $(el).addClass("hidden");
        }
      };
    setActiveParty(this, ev, activePartySlug);
    result.forEach(filterParties);
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
      $(this.categoriesSelector).delegate("a[data-category-id]", "click", fetchPromises.bind(this));
      $(this.partiesSelector).delegate("a[data-party-slug]", "click", filterByParty.bind(this));
    }
  }

}(HDO, jQuery));


