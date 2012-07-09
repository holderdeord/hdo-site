var HDO = HDO || {};

(function (H, $) {

    function updateSrc(img) {
        img.src = $(img).attr("data-src");
        $(img).removeAttr("data-src");
    }

    H.lazyLoadCarouselImages = {
        create: function (element) {
            if (!element) {
                throw new TypeError("HDO.lazyLoadCarouselImages requires an element");
            }
            var instance = Object.create(this);
            instance.element = element;
            return instance;
        },

        init: function () {
            $(this.element).on("slide", this.updateImageSrc.bind(this));
        },

        updateImageSrc: function () {
            var targetItem = $(this.element).find(".item").get(this.getActiveIndex() + 1),
                imgs = $(targetItem).find("img[data-src]");
            _.map(imgs, updateSrc);
        },

        getActiveIndex: function () {
            return $(this.element).find('.item.active').index();
        }
    };
}(HDO, jQuery));
