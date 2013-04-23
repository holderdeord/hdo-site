var HDO = HDO || {};

(function (H, $) {

  var emptyResultsMessage = '<div class="empty-results-message hidden">' +
                              '<h4>Partiet har ingen løfter i denne kategorien.</h4>' +
                            '</div>';

  function categoryChanged(el) {
    console.log($(el));
  }

  function partyChanged(el) {
    console.log($(el));
  }

  function subCategoryChanged(el) {
    console.log($(el));
  }

  HDO.promiseWidget = {
    create: function (params) {
      var instance = Object.create(this);
      instance.categoriesSelector = params.categoriesSelector;
      instance.partiesSelector = params.partiesSelector;
      instance.subCategoriesSelector = params.subCategoriesSelector;
      return instance;
    },

    init: function () {
      $(this.categoriesSelector).on("change", categoryChanged.bind(this));
      $(this.partiesSelector).on("change", partyChanged.bind(this));
      $(this.subCategoriesSelector).on("change", subCategoryChanged.bind(this));
    }
  };

}(HDO, jQuery));