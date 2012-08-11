(function ($, global) {
  $(document).ready(function () {
    // fix sub nav on scroll
    var $win = $(global);
    var $nav = $('.subnav');
    var navTop = $nav.length && $nav.outerHeight() - $nav.height();
    var isFixed = 0;

    function processScroll() {
      var scrollTop = $win.scrollTop();
      console.log(navTop, scrollTop);
      if (scrollTop >= navTop && !isFixed) {
        isFixed = 1;
        $nav.addClass('subnav-fixed');
      } else if (scrollTop <= navTop && isFixed) {
        isFixed = 0;
        $nav.removeClass('subnav-fixed');
      }
    }

    processScroll();

    // hack sad times - holdover until rewrite for 2.1
    $nav.on('click', function () {
      if (!isFixed) {
        setTimeout(function () {
          $win.scrollTop($win.scrollTop() - headerHeight - 7);
        }, 10);
      }
    });

    $win.on('scroll', processScroll);
  });
}(jQuery, window));