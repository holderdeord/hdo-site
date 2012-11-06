define(["jquery", "hdo/lazyLoadCarouselImages", "twitter/bootstrap"], function ($, lazyLoadCarouselImages) {

  return function (carousel) {
    var loader,
      prev;

    if (!carousel) { return; }

    loader = lazyLoadCarouselImages.create(carousel);
    loader.init();

    // Override carousel.prev, to avoid cycling backwards from the start frame.
    // Since we don't know which way we are sliding, we don't want to load images for more than one frame per slide.
    prev = $.fn.carousel.Constructor.prototype.prev;
    $.fn.carousel.Constructor.prototype.prev = function () {
      if (loader.getActiveIndex() === 0) { return; }
      prev.call(this);
    };

    $(carousel).carousel({interval: false});

  };

});