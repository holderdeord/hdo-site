(function ($, global) {
    $(document).ready(function () {
        // fix sub nav on scroll
        var $header, $win, $nav, navTop, isFixed, headerHeight;


        $win = $(global);
        $header = $('#HeaderNavigation');
        $nav = $header.find('.subnav:first');
        headerHeight = $header.height();
        navTop = headerHeight - $nav.height();
        isFixed = 0;

        function processScroll() {
            var scrollTop = $win.scrollTop();

            if (scrollTop >= navTop && !isFixed) {
                isFixed = 1;
                $header.addClass('header-fixed');
                $nav.addClass('subnav-fixed');
            } else if (scrollTop <= navTop && isFixed) {
                isFixed = 0;
                $header.removeClass('header-fixed');
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