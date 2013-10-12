describe('jquery.autoSelect', function () {
  it('should trigger form submit onchange', function () {
    var select = $("select");
    var form = $("form").append(select);

    var submitSpy = jasmine.createSpy;

    form.on("submit", function (e) {
      e.preventDefault();
      submitSpy();
    }.bind(this));

    // run function
    form.autoSelect();

    select.trigger("change");
    expect(submitSpy).toHaveBeenCalled;
  });
});
