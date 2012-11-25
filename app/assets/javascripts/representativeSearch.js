/*global cull */

var HDO = HDO || {};

(function (H, $, c) {

  function clearInput() {
    $(this).val("");
  }

  function parse(data) {
    var mapped = {};
    c.doall(function (obj) {
      var fullName = obj.first_name + " " + obj.last_name;
      mapped[fullName] = obj.slug;
    }, data);
    return mapped;
  }

  H.representativeSearch = {
    create: function (params) {
      var instance = Object.create(this);
      instance.mappedData = parse(params.data);
      return instance;
    },

    getSource: function () {
      return cull.keys(this.mappedData);
    },

    updater: function (name) {
      H.redirect("/representatives/" + this.mappedData[name]);
      return name;
    }
  };

  H.setupRepresentativeSearch = function (params) {
    var searcher = H.representativeSearch.create(params);
    $(params.element).typeahead({
      source: searcher.getSource(),
      updater: searcher.updater.bind(searcher)
    });

    $(params.element).on("focus", clearInput);
  };
}(HDO, $, cull));
