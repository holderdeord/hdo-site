describe("widgets", function() {
  var element;

  beforeEach(function() {
    HDO.widgets.baseUrl = "http://www.holderdeord.no/";
    element = document.createElement('div');

  });

  it("should create issue URLs", function() {
    var widget = HDO.widgets.create('issue')
    element.setAttribute('data-issue-id', '1');

    expect(widget.widgetOptionsFor(element).url).
      toEqual("http://www.holderdeord.no/issues/1/widget");
  });
});