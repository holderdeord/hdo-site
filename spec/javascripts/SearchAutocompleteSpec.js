describe('HDO.searchAutocomplete', function () {
  var input = cull.dom.el.input,
      form = cull.dom.el.form,
      div = cull.dom.el.div;

  var clock, server, searcher;

  beforeEach(function () {
    jasmine.Clock.useMock();
    server = jasmine.createSpyObj('server', ['search']);
    searcher = HDO.searchAutocomplete.create({
      server: server
    });
  });

  function getRepresentative(id) {
    return {
      full_name: "Test Name-" + id,
      url: "/test-url-" + id,
      latest_party: { name: "Party Hard" },
      img_src: "test-img-" + id
    };
  }

  it('should contact the server after 300ms', function () {
    var process = jasmine.createSpy('process');

    searcher.search("s", process);
    jasmine.Clock.tick(150);

    searcher.search("sk", process);
    jasmine.Clock.tick(150);

    searcher.search("ska", process);
    jasmine.Clock.tick(300);

    expect(server.search).toHaveBeenCalledWith("ska", jasmine.any(Function));
  });

  it("should parse issue data from server", function () {
    var issue = {title: "Test 1", url: "/test-1"};
    var parsed = searcher.parseIssue(issue);

    expect(parsed).toEqual("Test 1");
  });

  it("should map urls of parsed issues", function () {
    var issue = {title: "Test 1", url: "/test-1"};
    searcher.parseIssue(issue);

    expect(searcher.getUrl("Test 1")).toEqual("/test-1");
  });

  it("should map img url of parsed issue", function () {
    var issue = {title: "Test 1", url: "/test-1", img_src: "/test-img"};
    searcher.parseIssue(issue);

    expect(searcher.getImgSrc("Test 1")).toEqual("/test-img");
  });

  it("should parse representatives", function () {
    var parsed = searcher.parseRepresentative(getRepresentative(1));
    expect(parsed).toEqual("Test Name-1 (Party Hard)");
  });

  it("should map urls of parsed reps", function () {
    var parsed = searcher.parseRepresentative(getRepresentative(1));
    expect(searcher.getUrl(parsed)).toEqual("/test-url-1");
  });

  it("should map img src of parsed reps", function () {
    var parsed = searcher.parseRepresentative(getRepresentative(1));
    expect(searcher.getImgSrc(parsed)).toEqual("test-img-1");
  });

  it("should call process with parsed results", function () {
    var process = jasmine.createSpy('process');
    searcher.search("s", process);
    jasmine.Clock.tick(300);

    var data = {
      issue: [{title: "Test 1", url: "/test-1"}, {title: "Test 2", url: "/test-2"}],
      representative: [getRepresentative(1), getRepresentative(2)]
    };
    server.search.mostRecentCall.args[1](data); // invoke callback

    expect(process).toHaveBeenCalledWith(["Test 1", "Test 2", "Test Name-1 (Party Hard)", "Test Name-2 (Party Hard)"]);
  });

  it("should handle empty results", function () {
    var process = jasmine.createSpy('process');
    searcher.search("s", process);
    jasmine.Clock.tick(300);

    server.search.mostRecentCall.args[1]({}); // invoke callback
    expect(process).toHaveBeenCalledWith([]);
  });

  it("should redirect", function () {
    var listener = jasmine.createSpy('listener');
    HDO.redirect = listener;

    var issue = {title: "Test 1", url: "/test-1"};
    searcher.parseIssue(issue);

    searcher.redirect("Test 1");
    expect(listener).toHaveBeenCalledWith("/test-1");
  });

});
