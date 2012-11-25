/*global HDO */

var HDO = this.HDO || {};
var JZ = this.JZ || {};

(function (H, J) {
  H.searchServerFacade = J.serverFacade.create({
    search: function (query, callback) {
      var url = "/search/autocomplete";
      this.getJSON(url, {query: query}, {success: callback});
    }
  });
}(HDO, JZ));
