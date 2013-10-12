describe("HDO.widgets", function() {
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

  it("should create party URLs", function () {
    var widget = HDO.widgets.create('party')
    element.setAttribute('data-party-id', 'a');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/parties/a/widget");
  });

  it("should set issues correctly on a party", function () {
    var widget = HDO.widgets.create('party')
    element.setAttribute('data-party-id', 'a');
    element.setAttribute('data-issue-ids', '161');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/parties/a/widget?issues=161");
  });

  it("should set count correctly on a party", function () {
    var widget = HDO.widgets.create('party')
    element.setAttribute('data-party-id', 'a');
    element.setAttribute('data-count', '10');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/parties/a/widget?count=10");
  });

  it("should create representative URLs", function () {
    var widget = HDO.widgets.create('representative')

    element.setAttribute('data-representative-id', 'maaa')
    expect(widget.widgetOptionsFor(element).url).toEqual("http://www.holderdeord.no/representatives/maaa/widget");

    element.setAttribute('data-issue-ids', '1,2,3')
    expect(widget.widgetOptionsFor(element).url).toEqual("http://www.holderdeord.no/representatives/maaa/widget?issues=1%2C2%2C3");

    element.setAttribute('data-issue-ids', '')
    element.setAttribute('data-issue-count', '3')
    expect(widget.widgetOptionsFor(element).url).toEqual("http://www.holderdeord.no/representatives/maaa/widget?count=3");
  });

  it("should create topic URLs", function() {
    var widget = HDO.widgets.create('topic')
    element.setAttribute('data-issues', '1,2,3');
    element.setAttribute('data-promises', '{"Samferdsel":[101,102],"Intercity":[103,104]}');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/widgets/topic?issues=1%2C2%2C3&promises[Samferdsel]=101%2C102&promises[Intercity]=103%2C104");
  });

  it("should create promises URL", function() {
    var widget = HDO.widgets.create('promises')
    element.setAttribute('data-promises', '101,101,102');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/promises/101%2C101%2C102/widget");
  });

  it("should set target correctly on an issue", function () {
    var widget = HDO.widgets.create('issue')
    element.setAttribute('data-issue-id', '1');
    element.setAttribute('data-target', 'blank');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/issues/1/widget?target=blank");
  });

  it("should set target correctly on a topic", function () {
    var widget = HDO.widgets.create('topic')
    element.setAttribute('data-issues', '1,2,3');
    element.setAttribute('data-promises', '{"Samferdsel":[101,102]}');
    element.setAttribute('data-target', 'blank')

    expect(widget.widgetOptionsFor(element).url).toEqual(
     "http://www.holderdeord.no/widgets/topic?issues=1%2C2%2C3&promises[Samferdsel]=101%2C102&target=blank");
  });

  it("should set partner correctly", function () {
    var widget = HDO.widgets.create('issue')

    element.setAttribute('data-issue-id', '1');
    element.setAttribute('data-partner', 'nrk');

    expect(widget.widgetOptionsFor(element).url).toEqual(
      "http://www.holderdeord.no/issues/1/widget?partner=nrk");
  });

});