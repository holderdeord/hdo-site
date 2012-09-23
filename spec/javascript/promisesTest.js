/* global HDO*/

(function (H, $) {
  buster.testCase('Promises page - Categories', {
    setUp: function () {
      var el = $('<div id="categories">' +
                  '<li><a data-category-id=1>Arbeidsliv</a></li>' + 
                  '<li><a data-category-id=2>Finanser</a></li>' +
               '</div>');
      this.firstLink = $(el).find('a[data-category-id=1]').get(0);
      this.secondLink = $(el).find('a[data-category-id=2]').get(0);
      this.server = {
        fetchPromises: this.spy()
      }
      this.target = document.createElement("div");
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

      assert.match(this.target.innerHTML, "test");
    }
  });

  buster.testCase('Promises page - Parties', {
    setUp: function () {
      var partyEl = $('<div class="party-nav">' +
                    '<li class="show-all-active"><a data-party-slug=show-all>Alle partiene</a></li>' +
                    '<li><a data-party-slug=a>Arbeiderpartiet</a></li>' +
                    '<li><a data-party-slug=frp>Fremskritspariet</a></li>' +
                    '<li><a data-party-slug=government>Soria Moria</a></li>' +
                  '</div>' +
                  '<div id="categories">' + 
                    '<li><a data-category-id=1>Arbeidsliv</a></li>' + 
                    '<li><a data-category-id=2>Finanser</a></li>' +
                  '</div>');

      this.targetEl = $('<div id="promises-body">' +
                          '<div data-party-slug=a>' +
                            '<p>Promise 1</p>' +
                          '</div>' +
                          '<div data-party-slug=frp>' +
                            '<p>Promise 2</p>' +
                          '</div>' +
                          '<div data-party-slug=government>' +
                            '<p>Promsie 3</p>' +
                        '</div>');
                          
      this.server = {
        fetchPromises: this.spy()
      }

      this.firstPartyLink = $(partyEl).find('a[data-party-slug=a]').get(0);
      this.firstPartyLi = $(this.firstPartyLink).parent().get(0);
      
      this.secondPartyLink = $(partyEl).find('a[data-party-slug=frp]').get(0);
      this.secondPartyLi = $(this.secondPartyLink).parent().get(0);

      this.showAllLink = $(partyEl).find('a[data-party-slug="show-all"]').get(0);
      this.showAllLi = $(this.showAllLink).parent().get(0);

      this.soriaMoriaLink = $(partyEl).find('a[data-party-slug=government]').get(0);
      this.soriaMoriaLi = $(this.soriaMoriaLink).parent().get(0);

      this.firstCategoryLink = $('#categories').find('a[data-category-id=1]').get(0);
      this.secondCategoryLink = $('#categories').find('a[data-category-id=2]').get(0);

      this.widget = HDO.promiseWidget.create({
        categoriesSelector: $('#categories'),
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

      assert.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
      refute.className($(this.targetEl).find('div[data-party-slug=a]').get(0), "hidden");

      $(this.secondPartyLink).click();

      assert.className($(this.targetEl).find('div[data-party-slug=a]').get(0), "hidden");
      refute.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
    },

    "should give Soria Moria party government-active class when selected": function () {
      $(this.soriaMoriaLink).click();

      assert.className(this.soriaMoriaLi, "government-active");  
    },

    "should show all hidden divs when show all parties is selected": function () {
      $(this.firstCategoryLink).click();
      $(this.firstPartyLink).click();

      assert.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
      
      $(this.showAllLink).click();

      refute.className($(this.targetEl).find('div[data-party-slug=a]').get(0), "hidden");
      refute.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
    },

    "should show promises from selected party when categories are changed": function () {
      $(this.firstPartyLink).click();
      
      $(this.firstCategoryLink).click();

      assert.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
      assert.className($(this.targetEl).find('div[data-party-slug=government]').get(0), "hidden");
    }
  });
}(HDO, jQuery));