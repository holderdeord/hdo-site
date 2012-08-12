var HDO = HDO || {};

(function (H, $) {
  var categoryId, results, bodyName = "promisesBody";

  function getData(catId, partySlug, callback) {
    var correctUrl = partySlug == '' || partySlug == null ? '/categories/' + catId + '/promises' :
                                          '/categories/' + catId + '/promises?party=' + partySlug;
    $.ajax({
      url: correctUrl,
      success: function (data) {
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
    });
  }

  function showSpecificParty(catId, partyId) {
    var bodyElement = $('#' + bodyName);
    bodyElement.empty();

    if (partyId !== "showAll") {
      bodyElement.append(results).css('display', 'none');

      bodyElement.find('div').each(function () {
        if ($(this).attr('id') !== partyId) {
          $(this).hide();
        }
      });
      bodyElement.show();
    } else {
      showAllPromisesInCategory(catId, null);
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

        categoryId = $(this).attr('id');
        partySlug = null;

        if (self.options.partiesSelector == null) {
          partySlug = document.URL;
          partySlug = partySlug.substring(partySlug.lastIndexOf('/') + 1)
        } else {
          removeActiveClass(self.options.partiesSelector);
        }

        $('#showAll').parent().addClass('active');

        var target = $(self.options.targetSelector);
        target.empty().append('<div id="' + bodyName + '"></div>');

        showAllPromisesInCategory(categoryId, partySlug );
        console.log("here");
        e.preventDefault();
        return false;

      });

      $(self.options.partiesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.partiesSelector);
        $(this).parent().addClass('active');
        showSpecificParty(categoryId, $(this).attr('id'));

        e.preventDefault();
        return false;
      });
    } // end of init
  };
}(HDO, jQuery));