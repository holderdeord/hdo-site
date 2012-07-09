(function (H, $, _) {
    var carousel = document.getElementById("representative-carousel"),
        loader;
    if (!carousel) { return; }

    loader = H.lazyLoadCarouselImages.create(carousel);
    loader.init();

    // Override carousel.prev, to avoid cycling backwards from the start frame.
    // Since we don't know which way we are sliding, we don't want to load images for more than one frame per slide.
    $.fn.carousel.Constructor.prototype.prev = function () {
        if (this.sliding) { return; }
        if (loader.getActiveIndex() === 0) { return; }
        return this.slide('prev');
    };
}(HDO, window.jQuery, _));
