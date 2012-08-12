var HDO = HDO || {};

(function (H, $) {
  var categoryId, results, bodyName = "promisesBody";

  function getData(catId, callback) {
    $.ajax({
      url: '/category/' + catId + '/promises',
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

  function showAllPromisesInCategory(catId) {
    getData(catId, function (results) {
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
      showAllPromisesInCategory(catId);
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

        removeActiveClass(self.options.partiesSelector);
        $('#showAll').parent().addClass('active');

        var target = $(self.options.targetSelector);

        target.empty().append('<div id="' + bodyName + '"></div>');

        categoryId = $(this).attr('id');
        showAllPromisesInCategory(categoryId);

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
    }
  };
}(HDO, jQuery));