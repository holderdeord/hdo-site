(function ($) {
  $.fn.hideChildren = function (opts) {
    function create (element) {
      return $(document.createElement(element));
    }
    var options = $.extend({}, $.fn.hideChildren.defaults, opts);
    return this.each(function () {
      var $list = $(this),
          $children = $list.children(),
          $lastChild,
          $toggler,
          $toggleContainer,
          $layover;
      if ($children.length > options.startAtIndex + 2) {
        $layover = create("div").addClass("layover");
        $lastChild = $($children.get(options.startAtIndex - 1)).addClass("fader").append($layover);
        $children.slice(options.startAtIndex).hide();
        $toggleContainer = create("li").addClass("toggler").appendTo($list);
        $toggler = create("a").attr("href", "#").click(function (e) {
          e.preventDefault();
          $children.show();
          $toggleContainer.remove();
          $layover.remove();
          $lastChild.removeClass("fader");
        }).text(options.togglerText).appendTo($toggleContainer);
      }
    });
  };
  $.fn.hideChildren.defaults = {
    "startAtIndex": 3,
    "togglerText": "Vis alle"
  };
}(jQuery));