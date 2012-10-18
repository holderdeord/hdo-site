/* global HDO*/

(function (H, $) {
  buster.testCase('Promises page - Categories', {
    setUp: function () {
      var el = $('<div id="categories">' +
                  '<li><a data-category-id=1>Arbeidsliv</a></li>' + 
                  '<li><a data-category-id=2>Finanser</a></li>' +
               '</div>');
      this.firstLink = el.find('a[data-category-id=1]').get(0);
      this.secondLink = el.find('a[data-category-id=2]').get(0);
      this.server = {
        fetchPromises: this.spy()
      }
      this.target = $(document.createElement("div"));
      this.widget = HDO.promiseWidget.create({
        categoriesSelector: el, 
        server: this.server,
        targetEl: this.target
      });
      this.widget.init();
      
    },

    "category has active class when clicked": function () {
      $(this.firstLink).click();

      assert.className(this.firstLink, "active");
    },

    "only one category has active class": function () {
      $(this.firstLink).click();
      $(this.secondLink).click();

      refute.className(this.firstLink, "active");
      assert.className(this.secondLink, "active");
    },

    "should contact server when clicking on category": function () {
      $(this.firstLink).click();

      assert.calledOnceWith(this.server.fetchPromises, 1);
    },

    "should add results to page when category is clicked": function () {
      $(this.firstLink).click();

      this.server.fetchPromises.yield("test");

      assert.match(this.target.html(), "test");
    } 
  });

  buster.testCase('Promises page - Parties', {
    setUp: function () {
      var partyEl = $('<div class="party-nav">' +
                    '<li class="show-all-active"><a data-party-slug=show-all>Alle partiene</a></li>' +
                    '<li><a data-party-slug=a>Arbeiderpartiet</a></li>' +
                    '<li><a data-party-slug=frp>Fremskrittspariet</a></li>' +
                    '<li><a data-party-slug=v>Venstre</a></li>' +
                    '<li><a data-party-slug=government>Soria Moria</a></li>' +
                  '</div>');

      var categoryEl = $('<div id="categories">' + 
                          '<li><a data-category-id=1>Arbeidsliv</a></li>' + 
                          '<li><a data-category-id=2>Finanser</a></li>' +
                        '</div>');

      this.targetEl = $('<div class="promises-results">' +
                          '<div data-party-slug=a class="hidden">' +
                            '<p>Promise 1</p>' +
                          '</div>' +
                          '<div data-party-slug=frp class="hidden">' +
                            '<p>Promise 2</p>' +
                          '</div>' +
                          '<div data-party-slug=government class="hidden">' +
                            '<p>Promsie 3</p>' +
                          '</div>' + 
                          '<div class="empty-results-message hidden">Partiet har ingen løfter i denne kategorien.</div>' +
                        '</div>');

      this.server = {
        fetchPromises: this.spy()
      }

      this.firstPartyLink = partyEl.find('a[data-party-slug=a]').get(0);
      this.firstPartyLi = $(this.firstPartyLink).parent().get(0);
      
      this.secondPartyLink = partyEl.find('a[data-party-slug=frp]').get(0);
      this.secondPartyLi = $(this.secondPartyLink).parent().get(0);

      this.thirdPartyLink = partyEl.find('a[data-party-slug=v]').get(0);
      this.thirdPartyLi = $(this.thirdPartyLink).parent().get(0);

      this.showAllLink = partyEl.find('a[data-party-slug="show-all"]').get(0);
      this.showAllLi = $(this.showAllLink).parent().get(0);

      this.soriaMoriaLink = partyEl.find('a[data-party-slug=government]').get(0);
      this.soriaMoriaLi = $(this.soriaMoriaLink).parent().get(0);

      this.firstCategoryLink = categoryEl.find('a[data-category-id=1]').get(0);
      this.secondCategoryLink = categoryEl.find('a[data-category-id=2]').get(0);

      this.messageDiv = this.targetEl.find('.empty-results-message').get(0);

      this.widget = HDO.promiseWidget.create({
        categoriesSelector: categoryEl,
        partiesSelector: partyEl, 
        server: this.server,
        targetEl: this.targetEl,
        activeParty: this.showAllLi
      });
      this.widget.init();
    },

    "party has active class when clicked": function () {
      $(this.firstPartyLink).click();

      assert.className(this.firstPartyLi, "a-active");
      refute.className(this.showAllLi, "show-all-active");
    },

    "only one party has active class": function () {
      $(this.firstPartyLink).click();
      $(this.secondPartyLink).click();

      refute.className(this.firstPartyLi, "a-active");
      assert.className(this.secondPartyLi, "frp-active");
    },

    "only show selected party": function () {
      $(this.firstPartyLink).click();

      assert.className(this.targetEl.find('div[data-party-slug=frp]').get(0), "hidden");
      refute.className(this.targetEl.find('div[data-party-slug=a]').get(0), "hidden");

      $(this.secondPartyLink).click();

      assert.className(this.targetEl.find('div[data-party-slug=a]').get(0), "hidden");
      refute.className(this.targetEl.find('div[data-party-slug=frp]').get(0), "hidden");
    },

    "should give Soria Moria party government-active class when selected": function () {
      $(this.soriaMoriaLink).click();

      assert.className(this.soriaMoriaLi, "government-active");  
    },

    "should show all hidden divs when show all parties is selected": function () {
      $(this.firstCategoryLink).click();
      $(this.firstPartyLink).click();

      assert.className(this.targetEl.find('div[data-party-slug=frp]').get(0), "hidden");
      
      $(this.showAllLink).click();

      refute.className(this.targetEl.find('div[data-party-slug=a]').get(0), "hidden");
      refute.className(this.targetEl.find('div[data-party-slug=frp]').get(0), "hidden");
    },

    "should filter server response by selected party after selecting a new category":  function () {
      var responseHtml = this.targetEl.html(); 
      this.targetEl.html(''); // remove current promises to make sure we're filtering the server response

      $(this.firstPartyLink).click();
      $(this.firstCategoryLink).click();

      this.server.fetchPromises.yield(responseHtml);

      assert.className(this.targetEl.find('div[data-party-slug=frp]').get(0), "hidden");
      assert.className(this.targetEl.find('div[data-party-slug=government]').get(0), "hidden");
   },

   "should give a message if there are no promises to show": function () {
      $(this.firstPartyLink).click();
      assert.className(this.messageDiv, "hidden");

      $(this.thirdPartyLink).click();
      refute.className(this.messageDiv, "hidden");
   }
  });

  buster.testCase('Promises mobile page',{
    setUp: function () {
      this.categoryEl = $('<select class="categories">' +
                          '<option data-category-id=1>Arbeidsliv</option>' +
                          '<option data-category-id=2>Finanser</option>' +
                         '</select>"');

      this.subCategoriesEl = $('<select id="subcategory-dropdown" class="hidden"></select>');

      var partyEl = $('<select class="party-nav"' +
                        '<option data-party-slug=show-all selected=true></option>' +
                        '<option data-party-slug=a>Arbeiderpartiet</option>' +
                        '<option data-party-slug=frp>Fremskrittspariet</option>' +
                      '</select>');

      var targetEl = $('<div id=promises-results></div>');

      this.server = {
        fetchPromises: this.spy(),
        getSubCategories: this.spy()
      }

      this.widget = HDO.promiseWidget.create({
        categoriesSelector: this.categoryEl,
        partiesSelector: partyEl,
        server: this.server,
        targetEl: this.targetEl,
        activeParty: this.showAllLi,
        subCategoriesSelector: this.subCategoriesEl
      });
      this.widget.init();
    },

    "selected category should give correct category id": function () {
      this.categoryEl.val("Finanser").change();
      assert.equals(this.categoryEl.find('option:selected').data('category-id'), 2);

    },

    "when category is selected, subcategories should be visible": function () {
      this.categoryEl.val("Finanser").change();
      refute.className(this.subCategoriesEl.get(0), 'hidden');
    }
  });
}(HDO, jQuery));