var HDO = this.HDO || {};

(function (H, J) {
  
  H.promiseServerFacade = J.serverFacade.create({
    fetchPromises: function (categoryId, callback) {
      var url = '/categories/' + categoryId + '/promises';
      this.get(url, {}, { success: callback});
    }
  });
  
}(HDO, JZ));