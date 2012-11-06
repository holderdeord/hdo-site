define(["./serverFacade"], function (serverFacade) {

  return serverFacade.create({
    fetchPromises: function (categoryId, callback) {
      var url = '/categories/' + categoryId + '/promises';
      this.get(url, {}, { success: callback});
    },

    getSubCategories: function (categoryId, callback) {
      var url = '/categories/' + categoryId + '/subcategories';
      this.get(url, {}, { success: callback});
    }
  });

});