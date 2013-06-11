/*global HDO */

(function (H) {
  buster.testCase("widgets", {
    setUp: function () {
      H.widgets.baseUrl = "http://www.holderdeord.no/"
      this.element = document.createElement('div')
    },

    "should create issue URLs": function() {
      var widget = H.widgets.create('issue')
      this.element.setAttribute('data-issue-id', '1');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/issues/1/widget")
    },

    "should create party URLs": function() {
      var widget = H.widgets.create('party')
      this.element.setAttribute('data-party-id', 'a');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/parties/a/widget")
    },

    "should set issues correctly on a party": function () {
      var widget = H.widgets.create('party')
      this.element.setAttribute('data-party-id', 'a');
      this.element.setAttribute('data-issue-ids', '161');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/parties/a/widget?issues=161")
    },

    "should set count correctly on a party": function () {
      var widget = H.widgets.create('party')
      this.element.setAttribute('data-party-id', 'a');
      this.element.setAttribute('data-count', '10');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/parties/a/widget?count=10")
    },

    "should create representative URLs": function () {
      var widget = H.widgets.create('representative')

      this.element.setAttribute('data-representative-id', 'maaa')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget");

      this.element.setAttribute('data-issue-ids', '1,2,3')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget?issues=1%2C2%2C3");

      this.element.setAttribute('data-issue-ids', '')
      this.element.setAttribute('data-issue-count', '3')
      assert.equals(widget.widgetOptionsFor(this.element).url, "http://www.holderdeord.no/representatives/maaa/widget?count=3");
    },

    "should create topic URLs": function() {
      var widget = H.widgets.create('topic')
      this.element.setAttribute('data-issues', '1,2,3');
      this.element.setAttribute('data-promises', '{"Samferdsel":[101,102],"Intercity":[103,104]}');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/widgets/topic?issues=1%2C2%2C3&promises[Samferdsel]=101%2C102&promises[Intercity]=103%2C104")
    },

    "should create promises URL": function() {
      var widget = H.widgets.create('promises')
      this.element.setAttribute('data-promises', '101,101,102');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/promises/101%2C101%2C102/widget")
    },

    "should set target correctly on an issue": function () {
      var widget = H.widgets.create('issue')
      this.element.setAttribute('data-issue-id', '1');
      this.element.setAttribute('data-target', 'blank');

      assert.equals(widget.widgetOptionsFor(this.element).url,
        "http://www.holderdeord.no/issues/1/widget?target=blank")
    },

    "should set target correctly on a topic": function () {
      var widget = H.widgets.create('topic')
      this.element.setAttribute('data-issues', '1,2,3');
      this.element.setAttribute('data-promises', '{"Samferdsel":[101,102]}');
      this.element.setAttribute('data-target', 'blank')

      assert.equals(widget.widgetOptionsFor(this.element).url,
      "http://www.holderdeord.no/widgets/topic?issues=1%2C2%2C3&promises[Samferdsel]=101%2C102&target=blank")
    }

  });
}(HDO));