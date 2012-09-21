var HDO = HDO || {};

(function (H, $) {
  var categoryId,
    partySlug = 'show-all',
    results,
    bodyName = "promises-body",
    lastPartyFilter = null;

  function getData(cache, catId, partySlug, callback) {
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

  function showSpecificParty(partyId) {
    lastPartyFilter = partyId;
    var bodyElement = $('.' + bodyName);
    bodyElement.html(results);
  }

  function showAllPromisesInCategory(cache, catId, partySlug) {
    getData(cache, catId, partySlug, function (results) {
      lastPartyFilter = partySlug;
      if (results !== '') {
        setResults(results);
        $('.' + bodyName).html(results);
        showSpecificParty(lastPartyFilter);
      } else {
        $('.' + bodyName).html("Partiet har ingen løfter i denne kategorien.");
      }
    });
  }

  function showAllParties(catId) {
    lastPartyFilter = null;
    showAllPromisesInCategory(catId, "show-all");
  }

  function removeActiveClass(divClass) {
    $(divClass).find('li').removeClass();
  }

  function showSubCategories(categoryId) {
    $.ajax({
      url: "/categories/" + categoryId + "/subcategories",

      success:  function (subcategories) {
        $('#subcategory-dropdown').empty().append('<option>Velg underkategori</option>').val(0);
        $.each(subcategories, function (i, value) {
          $('#subcategory-dropdown').append('<option data-category-id="' + value.id + '">' +
            value.name + '</option>').show();
        });
      }
    });
  }

  H.promiseWidget = {
    create: function (options) {
      var instance = Object.create(this);
      instance.options = options;
      instance.cache = {};

      return instance;
    },

    init: function () {
      var self = this;

      $(self.options.categoriesSelector).find('a').on('click', function (e) {
        categoryId = $(this).data('category-id');

        $(self.options.categoriesSelector).find('a').removeClass('active');
        $(this).addClass('active');

        var target = $(self.options.targetSelector);
        target.empty().append('<div class="' + bodyName + '"></div>');

        if (self.options.partiesSelector !== null) {
          if (!lastPartyFilter) {
            removeActiveClass(self.options.partiesSelector);
            $('[data-party-slug="show-all"]').parent().addClass('active');
          }
        } else {
          partySlug = document.URL;
          partySlug = partySlug.substring(partySlug.lastIndexOf('/') + 1);
        }

        showAllPromisesInCategory(self.cache, categoryId, partySlug);

        e.preventDefault();

      });

      $(self.options.partiesSelector).find('a').on('click', function (e) {
        removeActiveClass(self.options.partiesSelector, partySlug);

        partySlug = $(this).data('party-slug');

        if (partySlug.indexOf(',') >= 0) {
          $(this).parent().addClass('government-active');
        } else {
          $(this).parent().addClass(partySlug + '-active');
        }

        if (partySlug !== lastPartyFilter) {
          showAllPromisesInCategory(self.cache, categoryId, partySlug);
          showSpecificParty(partySlug);
        } else {
          showSpecificParty(partySlug);
        }

        e.preventDefault();
      });

      //category dropdown list mobile
      $(self.options.categoriesSelector).on('change', function () {
        categoryId = $(self.options.categoriesSelector + " option:selected").data("category-id");
        showSubCategories(categoryId);
        showAllPromisesInCategory(self.cache, categoryId, partySlug);
      });

      //subcategory dropdown list mobile
      $('#subcategory-dropdown').on('change', function () {
        categoryId = $("#subcategory-dropdown option:selected").data("category-id");
        showAllPromisesInCategory(self.cache, categoryId, partySlug);
        $('#subcategory-dropdown option:selected').attr('selected', 'true');
      });

      //party dropdown list mobile
      $(self.options.partiesSelector).on('change', function () {
        var target = $(self.options.targetSelector);
        partySlug = $(self.options.partiesSelector + " option:selected").data("party-slug");
        if (categoryId) {
          target.empty().append('<div class="' + bodyName + '"></div>');
          showAllPromisesInCategory(self.cache, categoryId, partySlug);
        } else {
          target.empty().append("Ingen kategori valgt.");
        }
      });
    } // end of init
  };
}(HDO, jQuery));