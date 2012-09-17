var HDO = HDO || {};

(function (H, $) {
  var categoryId,
    partySlug = 'show-all',
    results,
    bodyName = "promises-body",
    cache = {},
    lastPartyFilter = null;

  function getData(catId, partySlug, callback) {
    var promiseUrl;

    if (partySlug === '' || !partySlug || partySlug === "show-all") {
      promiseUrl = '/categories/' + catId + '/promises';
    } else {
      promiseUrl = '/categories/' + catId + '/promises/parties/' + partySlug;
    }

    if (cache[promiseUrl]) {
      callback(cache[promiseUrl]);
      return;
    }

    $("#spinner").show();

    $.ajax({
      url: promiseUrl,

      complete: function () {
        $("#spinner").hide();
      },

      success: function (data) {
        cache[promiseUrl] = data;
        callback(data);
      }
    });
  }

  function setResults(data) {
    results = data;
  }

  function showAllPromisesInCategory(catId, partySlug) {
    getData(catId, partySlug, function (results) {
      if (results !== "") {
        setResults(results);
        $('.' + bodyName).html(results);
      } else {
        $('.' + bodyName).html("Partiet har ingen løfter i denne kategorien.");
      }
    });
  }

  function showAllParties(catId) {
    lastPartyFilter = null;
    showAllPromisesInCategory(catId);
  }

  function removeActiveClass(divClass) {
    $(divClass).find('li').removeClass();
  }

  H.promiseWidget = {
    create: function (options) {
      var instance = Object.create(this);
      instance.options = options;

      return instance;
    },

    init: function () {
      var self = this;

      $(self.options.categoriesSelector).find('a').on('click', function (e) {

        categoryId = $(this).data('category-id');

        $(self.options.categoriesSelector).find('a').removeClass('active');
        $(this).addClass('active');

        if (self.options.partiesSelector !== null) {
          if (!lastPartyFilter) {
            removeActiveClass(self.options.partiesSelector);
            $('[data-party-slug="show-all"]').parent().addClass('active');
          }
        } else {
          partySlug = document.URL;
          partySlug = partySlug.substring(partySlug.lastIndexOf('/') + 1);
        }

        var target = $(self.options.targetSelector);
        target.empty().append('<div class="' + bodyName + '"></div>');
        showAllPromisesInCategory(categoryId, partySlug);

        e.preventDefault();

      });

      $(self.options.partiesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.partiesSelector, partySlug);

        partySlug = $(this).data('party-slug');
        lastPartyFilter = partySlug;

        if (partySlug.indexOf(',') >= 0) {
          $(this).parent().addClass('government-active');
        } else {
          $(this).parent().addClass(partySlug + '-active');
        }

        showAllPromisesInCategory(categoryId, partySlug);

        e.preventDefault();
      });

      //category dropdown list mobil
      $(self.options.categoriesSelector).on('change', function () {
        categoryId = $(self.options.categoriesSelector + " option:selected").data("category-id");
        showAllPromisesInCategory(categoryId, partySlug);
      });

      //party dropdown list mobile
      $(self.options.partiesSelector).on('change', function () {
        var target = $(self.options.targetSelector);
        partySlug = $(self.options.partiesSelector + " option:selected").data("party-slug");
        if (categoryId) {
          target.empty().append('<div class="' + bodyName + '"></div>');
          showAllPromisesInCategory(categoryId, partySlug);
        } else {
          target.empty().append("Ingen kategori valgt.");
        }
      });
    } // end of init
  };
}(HDO, jQuery));