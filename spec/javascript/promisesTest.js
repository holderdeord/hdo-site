/* global HDO*/

(function (H, $) {
  buster.testCase('Promises page', {
    setUp: function () {
      this.server = sinon.fakeServer.create();
    },

    tearDown: function () {
      this.server.restore();
    },

    "//should render the server response when a category is clicked": function() {
      var el = $('<div id="categories"><a data-category-id="1">Arbeidsliv</a></div> <div id="target"></div>');
      $(document.body).append(el);
      var serverResponse = '<div>some promise</div>';

      this.server.respondWith('GET', '/categories/1/promises',
        [200, {'Content-Type': 'text/html'}, serverResponse]);

      H.promiseWidget.create({
        categoriesSelector: '#categories',
        targetSelector: '#target'
      }).init();

      el.find('a').click();

      // assert server called
      assert.match(this.server.requests[0], {
        method: 'GET',
        url: '/categories/1/promises'
      });

      this.server.respond();

      // assert html response rendered
      var target = $('#target');
      var expectedHtml = '<div class="promises-body">' + serverResponse + '</div>';

      assert.equals(target.html(), expectedHtml);
    },

    "//party filter should not change when choosing other categories": function () {
      var mockHtmlObject = $('<div id="categories"><a data-category-id="1">Arbeidsliv</a>' + 
        '<a data-category-id="2">Finanser</a></div><div class="party-nav"><li><a data-party-slug="show-all">Alle partiene</a></li>' + 
        '<li class="a-active"><a data-party-slug="a">Arbeiderpartiet</a></li></div>');
      $(document.body).append(mockHtmlObject);   
      var mockHtml = mockHtmlObject.html();

      this.server.respondWith('GET', 'categories/1/promises',
        [200, {'Content-Type': 'text/html'}, '']);

      this.server.respondWith('GET', 'categories/1/promises/parties/a',
        [200, {'Content-Type': 'text/html'}, mockHtml]);

      this.server.respondWith('GET', 'categories/2/promises/parties/a',
        [200, {'Content-Type': 'text/html'}, mockHtml]);

      H.promiseWidget.create({
        categoriesSelector: '#categories',
        partiesSelector: '.party-nav'
      }).init();

      mockHtmlObject.find('a[data-category-id=1]').click();
      assert.equals(this.server.requests.length, 1);
      this.server.respond();

      mockHtmlObject.find('a[data-party-slug=a]').click();
      assert.equals(this.server.requests.length, 2);
      this.server.respond();

      mockHtmlObject.find('a[data-category-id=2]').click();
      assert.equals(this.server.requests.length, 3);
      this.server.respond();

      assert.match(this.server.requests[1], {
        method: 'GET',
        url: '/categories/1/promises/parties/a'
      });

      assert.match(this.server.requests[2], {
        method: 'GET',
        url: '/categories/2/promises/parties/a'
      });
    },

    "//caches server responses": function() {
      var mockHtmlObject = $('<div id="categories"><a data-category-id="1">Arbeidsliv</a></div>' + 
        '<div class="party-nav"><li><a data-party-slug="show-all">Alle partiene</a></li>' + 
        '<li class="a-active"><a data-party-slug="a">Arbeiderpartiet</a></li></div>');
      $(document.body).append(mockHtmlObject);   
      var mockHtml = mockHtmlObject.html();

      this.server.respondWith('GET', 'categories/1/promises',
        [200, {'Content-Type': 'text/html'}, mockHtml]);

      H.promiseWidget.create({
        categoriesSelector: '#categories',
        partiesSelector: '.party-nav'
      }).init();

      mockHtmlObject.find('a[data-category-id=1]').click();
      assert.equals(this.server.requests.length, 1);
      this.server.respond();

      mockHtmlObject.find('a[data-party-slug=a]').click();
      assert.equals(this.server.requests.length, 2);
      this.server.respond();

      mockHtmlObject.find('a[data-party-slug=show-all]').click();
      assert.equals(this.server.requests.length, 2);
      this.server.respond();
    },

    "//should show message when there are no promises": function () {
      var mockHtmlObject = $('<div id="categories"><a data-category-id="1">Arbeidsliv</a></div>' + 
        '<div class="party-nav"><li><a data-party-slug="show-all">Alle partiene</a></li>' + 
        '<li class="a-active"><a data-party-slug="a">Arbeiderpartiet</a></li></div>');
      $(document.body).append(mockHtmlObject);
      var response = "Partiet har ingen løfter i denne kategorien.";

      this.server.respondWith('GET', 'categories/1/promises',
        [200, {'Content-Type': 'text/html'}, '']);

      this.server.respondWith('GET', 'categories/1/promises/parties/a',
        [200, {'Content-Type': 'text/html'}, response]);

      H.promiseWidget.create({
        categoriesSelector: '#categories',
        partiesSelector: '.party-nav',
        targetSelector: '#target'
      }).init();

      mockHtmlObject.find('a[data-category-id=1]').click();
      this.server.respond();

      mockHtmlObject.find('a[data-party-slug=a]').click();
      assert.match(this.server.requests[1], {
        method: 'GET',
        url: '/categories/1/promises/parties/a'
      });
      this.server.respond();

      target = $('#target');
      var expectedHtml = '<div id="promises-body">' + response + '</div>';
      assert.equals(target.html(), expectedHtml);
    }
  });

    

}(HDO, jQuery));