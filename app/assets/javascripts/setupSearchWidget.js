/*global HDO */

(function (H) {

  H.setupSearchWidget = function () {
    var input = document.getElementById("searchInput"),
      resultEl = document.getElementById("searchResult"),
      server = H.searchServerFacade.create(),
      searcher = H.search.create({
        input: input,
        resultElement: resultEl,
        server: server
      });

    searcher.init();
  };

}(HDO));
