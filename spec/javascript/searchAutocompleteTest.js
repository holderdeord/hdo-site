/*global HDO, cull */

(function (H, cull) {
  var input = cull.dom.el.input;
  var form = cull.dom.el.form;
  var div = cull.dom.el.div;

  function getRepresentative(id) {
    return {
      full_name: "Test Name-" + id,
      url: "/test-url-" + id,
      latest_party: {
        name: "Party Hard"
      },
      img_src: "test-img-" + id
    };
  }

  buster.testCase("SearchAutocomplete", {
    setUp: function () {
      this.clock = sinon.useFakeTimers();
      this.server = {
        search: this.stub()
      };

      this.searcher = HDO.searchAutocomplete.create({
        server: this.server
      });
    },

    "should contact server after 300ms": function () {
      var process = this.spy();
      this.searcher.search("s", process);
      this.clock.tick(150);

      this.searcher.search("sk", process);
      this.clock.tick(150);

      this.searcher.search("ska", process);
      this.clock.tick(300);

      assert.calledOnceWith(this.server.search, "ska");
    },

    "should parse issue data from server": function () {
      var issue = {title: "Test 1", url: "/test-1"};
      var parsed = this.searcher.parseIssue(issue);
      assert.equals(parsed, "Test 1");
    },

    "should map urls of parsed issues": function () {
      var issue = {title: "Test 1", url: "/test-1"};
      this.searcher.parseIssue(issue);
      assert.equals(this.searcher.getUrl("Test 1"), "/test-1");
    },

    "should map img url of parsed issue": function () {
      var issue = {title: "Test 1", url: "/test-1", img_src: "/test-img"};
      this.searcher.parseIssue(issue);
      assert.equals(this.searcher.getImgSrc("Test 1"), "/test-img");
    },

    "should parse representatives": function () {
      var parsed = this.searcher.parseRepresentative(getRepresentative(1));
      assert.equals(parsed, "Test Name-1 (Party Hard)");
    },

    "should map urls of parsed reps": function () {
      var parsed = this.searcher.parseRepresentative(getRepresentative(1));
      assert.equals(this.searcher.getUrl(parsed), "/test-url-1");
    },

    "should map img src of parsed reps": function () {
      var parsed = this.searcher.parseRepresentative(getRepresentative(1));
      assert.equals(this.searcher.getImgSrc(parsed), "test-img-1");
    },

    "should call process with parsed results": function () {
      var process = this.spy();
      this.searcher.search("s", process);
      this.clock.tick(300);

      var data = {
        issue: [{title: "Test 1", url: "/test-1"}, {title: "Test 2", url: "/test-2"}],
        representative: [getRepresentative(1), getRepresentative(2)]
      };
      this.server.search.yield(data);

      assert.calledOnceWith(process, ["Test 1", "Test 2", "Test Name-1 (Party Hard)", "Test Name-2 (Party Hard)"]);
    },

    "should handle empty results": function () {
      var process = this.spy();
      this.searcher.search("s", process);
      this.clock.tick(300);

      this.server.search.yield({});
      assert.calledOnceWith(process, []);
    },

    "should redirect": function () {
      var listener = this.spy();
      H.redirect = listener;

      var issue = {title: "Test 1", url: "/test-1"};
      this.searcher.parseIssue(issue);

      this.searcher.redirect("Test 1");
      assert.calledOnceWith(listener, "/test-1");
    }

  });
}(HDO, cull));
