/*global HDO, cull */

(function (H, $, c) {

  HDO.searchAutocomplete = {
    create: function (params) {
      var instance = Object.create(this);
      instance.server = params.server;
      instance.throttler = HDO.throttler.create(300);
      instance.urlMap = {};
      return instance;
    },

    search: function (query, process) {
      var self = this;
      return this.throttler.queue(query, function (q) {
        self.contactServer(q, function (data) {
          var result = [];
          if (data.issue) {
            result.push(cull.map(self.parseIssue.bind(self), data.issue));
          }
          if (data.representative) {
            result.push(cull.map(self.parseRepresentative.bind(self), data.representative));
          }
          process(cull.flatten(result));
        });
      });
    },

    contactServer: function (query, callback) {
      this.server.search(query, callback);
    },

    parseIssue: function (issue) {
      var label = issue.title;
      this.urlMap[label] = issue.url;
      return label;
    },

    parseRepresentative: function (rep) {
      var label = rep.full_name + " (" + rep.current_party.name + ")";
      this.urlMap[label] = rep.url;
      return label;
    },

    getUrl: function (label) {
      return this.urlMap[label];
    },

    redirect: function (label) {
      H.redirect(this.getUrl(label));
      return label;
    }
  };

  H.setupSearchWidget = function () {
    var input = document.getElementById("searchInput");
    var autocomplete = H.searchAutocomplete.create({
      server: H.searchServerFacade.create()
    });
    $(input).typeahead({
      source: autocomplete.search.bind(autocomplete),
      updater: autocomplete.redirect.bind(autocomplete),
      items: 15,
      minLength: 3
    });
  };

}(HDO, jQuery, cull));
