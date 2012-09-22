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
      var el = $('<div class="party-nav">' +
                    '<li><a data-party-slug=a>Arbeiderpartiet</a></li>' +
                    '<li><a data-party-slug=frp>Fremskritspariet</a></li>' +
                  '</div>');

      this.targetEl = $('<div id="promises-body">' +
                          '<div data-party-slug=a>' +
                            '<h3 class="a-title"><a href="/parties/a">Arbeiderpartiet</a></h3>' +
                              '<p>Promise 1</p>' +
                          '</div>' +
                          '<div data-party-slug=frp>' +
                            '<h3 class="frp-title"><a href="/parties/frp">Fremskritspariet</a></h3>' +
                              '<p>Promise 2</p>' +
                          '</div>' +
                        '</div>');
                          

      this.firstLink = $(el).find('a[data-party-slug=a]').get(0);
      this.firstLi = $(this.firstLink).parent().get(0);
      
      this.secondLink = $(el).find('a[data-party-slug=frp]').get(0);
      this.secondLi = $(this.secondLink).parent().get(0);

      this.widget = HDO.promiseWidget.create({
        partiesSelector: el, 
        server: this.server,
        targetEl: this.targetEl
      });
      this.widget.init();
    },

    "party has active class when clicked": function () {
      $(this.firstLink).click();

      assert.className(this.firstLi, "active");
    },

    "only one party has active class": function () {
      $(this.firstLink).click();
      $(this.secondLink).click();

      refute.className(this.firstLi, "active");
      assert.className(this.secondLi, "active");
    },

    "only show selected party": function () {
      $(this.firstLink).click();

      assert.className($(this.targetEl).find('div[data-party-slug=frp]').get(0), "hidden");
      refute.className($(this.targetEl).find('div[data-party-slug=a]').get(0), "hidden");
    }
  });
}(HDO, jQuery));