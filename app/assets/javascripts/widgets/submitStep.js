define(["jquery"], function ($) {
  function submitStep(step) {
    var form = $('.edit_issue');
    $('<input>').attr({
      type: 'hidden',
      id: 'step-name',
      name: 'next_step',
      value: step
    }).appendTo(form);
    form.submit();
  }

  return function (element) {
    $(element).on("click", "li a", function (e) {
      submitStep(e.target.getAttribute("data-step"));
    });
  };
});