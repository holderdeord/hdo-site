var HDO = this.HDO || {};
var JZ = this.JZ || {};

(function (H, J) {

  H.promiseServerFacade = J.serverFacade.create({
    fetchPromises: function (categoryId, callback) {
      var url = '/categories/' + categoryId + '/promises';
      this.get(url, {}, { success: callback});
    },

    getSubCategories: function (categoryId, callback) {
      var url = '/categories/' + categoryId + '/subcategories';
      this.get(url, {}, { success: callback});
    }
  });
}(HDO, JZ));