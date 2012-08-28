var HDO = HDO || {};

(function (H, $) {
  var categoryId,
    partySlug = null,
    results,
    bodyName = "promisesBody",
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

  function getResults() {
    return results;
  }

  function showSpecificParty(catId, partyId) {
    var bodyElement = $('#' + bodyName);
    bodyElement.empty();

    lastPartyFilter = partyId;

    bodyElement.hide().append(results);
    bodyElement.find('div[data-party-slug!="' + partyId + '"]').hide();
    bodyElement.show();
  }

  function showAllPromisesInCategory(catId, partySlug) {
    getData(catId, partySlug, function (results) {
      setResults(results);
      $('#' + bodyName).html(results);
      if (lastPartyFilter) {
        showSpecificParty(catId, lastPartyFilter);
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
        target.empty().append('<div id="' + bodyName + '"></div>');
        showAllPromisesInCategory(categoryId, partySlug);

        e.preventDefault();

      });

      $(self.options.partiesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.partiesSelector, partySlug);

        partySlug = $(this).data('party-slug');

        if(partySlug.indexOf(',') >= 0) {
          $(this).parent().addClass('government-active');
        } else {
          $(this).parent().addClass(partySlug + '-active');
        }

        if (partySlug === 'show-all') {
          showAllParties(categoryId);
          $(this).parent().addClass('active');
        } else {
          showSpecificParty(categoryId, partySlug);
        }

        e.preventDefault();
      });
    } // end of init
  };
}(HDO, jQuery));