/*global HDO, cull */

(function (H, $, c) {

  HDO.searchAutocomplete = {
    create: function (params) {
      var instance = Object.create(this);
      instance.server = params.server;
      instance.throttler = HDO.throttler.create(150);
      instance.nameMap = {};
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
      this.nameMap[label] = {
        url: issue.url,
        img: issue.img_src
      };
      return label;
    },

    parseRepresentative: function (rep) {
      var label = rep.full_name + " (" + rep.party_name + ")";
      this.nameMap[label] = {
        url: rep.url,
        img: rep.img_src
      };
      return label;
    },

    getUrl: function (label) {
      return this.nameMap[label].url;
    },

    getImgSrc: function (label) {
      return this.nameMap[label].img;
    },

    redirect: function (label) {
      H.redirect(this.getUrl(label));
      return label;
    }
  };

  H.setupSearchWidget = function () {
    var input, autocomplete;

    input = document.getElementById("appendedInputButton");

    autocomplete = H.searchAutocomplete.create({
      server: H.searchServerFacade.create()
    });

    $(input).typeahead({
      source: autocomplete.search.bind(autocomplete),
      updater: autocomplete.redirect.bind(autocomplete),
      items: 15,
      minLength: 3,
      matcher: function () { return true; },
      highlighter: function (item) {
        return "<img src='" + autocomplete.getImgSrc(item) +
          "' width='24' height='24'>" + item;
      }
    });
  };

}(HDO, jQuery, cull));
