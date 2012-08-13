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

    if (partySlug === '' || partySlug === null) {
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

  function showAllPromisesInCategory(catId, partySlug) {
    getData(catId, partySlug, function (results) {
      setResults(results);
      $('#' + bodyName).html(results);
      if (lastPartyFilter) {
        showSpecificParty(catId, lastPartyFilter);
      }
    });
  }

  function showSpecificParty(catId, partyId) {
    var bodyElement = $('#' + bodyName);
    bodyElement.empty();

    if (partyId === "show-all") {
      lastPartyFilter = null;
      showAllPromisesInCategory(catId, null);
    } else {
      lastPartyFilter = partyId;
      bodyElement.hide().append(results);

      bodyElement.find('div').each(function () {
        if ($(this).data('party-slug') !== partyId) {
          $(this).hide();
        }
      });
      bodyElement.show();
    }
  }

  function removeActiveClass(divClass) {
    $(divClass).find('li').removeClass('active');
  }

  H.promiseWidget = {
    create: function (options) {
      var instance = Object.create(this);
      instance.options = options;

      return instance;
    },

    init: function () {
      var self = this;

      $(self.options.categoriesSelector).css('border-right', 'solid 1px #EEE');

      $(self.options.categoriesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.categoriesSelector);
        $(this).parent().addClass('active');

        categoryId = $(this).data('category-id');

        if (self.options.partiesSelector !== null) {
          // $(self.options.partiesSelector).show();
          if (!lastPartyFilter) {
            removeActiveClass(self.options.partiesSelector);
            $('#show-all').parent().addClass('active');
          }
        } else {
          partySlug = document.URL;
          partySlug = partySlug.substring(partySlug.lastIndexOf('/') + 1);
        }


        var target = $(self.options.targetSelector);
        target.empty().append('<div id="' + bodyName + '"></div>');

        showAllPromisesInCategory(categoryId, partySlug);
        e.preventDefault();
        return false;

      });

      $(self.options.partiesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.partiesSelector);
        $(this).parent().addClass('active');
        showSpecificParty(categoryId, $(this).data('party-slug'));

        e.preventDefault();
        return false;
      });
    } // end of init
  };
}(HDO, jQuery));