/* global HDO */

(function (H, $) {
  buster.testCase('Lazy Load Carousel Images', {
    setUp: function () {
      this.element = document.createElement("div");
      this.element.id = "representative-carousel";
      this.element.innerHTML = "<div class='carousel-inner'><div class='item active'>" +
        "<img alt='Marianne Aasen' class='representative-carousel-image' src='/assets/1.jpg' /> " +
        "<img alt='Terje Aasland' class='representative-carousel-image' src='/assets/2.jpg' />" +
        "</div><div class='item'>" +
        "<img id='3' alt='Dag Terje Andersen' class='representative-carousel-image' src='' data-src='/assets/3.jpg' />" +
        "<img alt='Bendiks H. Arnesen' class='representative-carousel-image' src='' data-src='/assets/4.jpg' />" +
        "<img alt='Jorodd Asphjell' class='representative-carousel-image' src='' data-src='/assets/5.jpg' />" +
        "<img alt='Eva Vinje Aurdal' class='representative-carousel-image' src='' data-src='/assets/6.jpg' />" +
       "</div></div>";

      this.loader = H.lazyLoadCarouselImages.create(this.element);
      this.loader.init();
    },

    "should require an element": function () {
      assert.exception(function () {
        H.lazyLoadCarouselImages.create();
      }, "TypeError");
    },

    "should give index of current active item": function () {
      assert.equals(this.loader.getActiveIndex(), 0);

      $(this.element).find(".active").removeClass("active");
      $(this.element).find(".item").last().addClass("active");

      assert.equals(this.loader.getActiveIndex(), 1);
    },

    "should update img src from data-src": function () {
      this.loader.updateImageSrc();
      assert.match($(this.element).find("#3").get(0).src, "/assets/3.jpg");
    },

    "should remove data-src": function () {
      this.loader.updateImageSrc();
      var img = $(this.element).find("#3");

      refute(img.attr("data-src"));
    },

    "should update src on 'slide' event": function () {
      $(this.element).trigger("slide");

      refute($(this.element).find("img[data-src]").get(0));
    }
  });

}(HDO, jQuery));