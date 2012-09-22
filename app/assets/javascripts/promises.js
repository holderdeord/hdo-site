var HDO = HDO || {};

(function (H, $) {

  function setActiveLink (self, activeType, element) {
    if(self[activeType]) {
      $(self[activeType]).removeClass("active");
    }
    self[activeType] = element;
    $(self[activeType]).addClass("active");
  }

  function insertCategoriesInTarget (data) {
      this.targetEl.innerHTML = data;
  }

  function fetchPromises(ev) {
    setActiveLink(this, "activeCategory", ev.currentTarget);
    var categoryId = $(this.activeCategory).data("category-id");
    this.server.fetchPromises(categoryId, insertCategoriesInTarget.bind(this));
    return false;
  }

  function filterByParty(ev) {
    setActiveLink(this, "activeParty", $(ev.currentTarget).parent().get(0));

    var activeParty = $(ev.currentTarget).data("party-slug");
    var result = $(this.targetEl).find("div[data-party-slug]").get();

    var filterParties = function (el) {
      if($(el).data("party-slug") === activeParty) {
        $(el).removeClass("hidden");
      } else {
        $(el).addClass("hidden");
      }
    }  

    result.forEach(filterParties);
    return false;
  } 

  HDO.promiseWidget = {
    create: function(params) {
      var instance = Object.create(this);
      instance.server = params.server;
      instance.categoriesSelector = params.categoriesSelector;
      instance.activeCategory = null;
      instance.activeParty = null;
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


