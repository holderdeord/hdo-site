var config = module.exports;

config["HDO javascript tests"] = {
    rootPath: "../",
    environment: "browser",
    sources: [
        "spec/javascript/lib/*.js",
        "app/assets/javascripts/lib/lodash-0.3.2.min.js",
        "app/assets/javascripts/lib/*.js",
        "app/assets/javascripts/lazyLoadCarouselImages.js",
        "app/assets/javascripts/representativeSearch.js",
        "app/assets/javascripts/promises.js",
        "app/assets/javascripts/throttler.js",
        "app/assets/javascripts/searchAutocomplete.js",
        "app/assets/javascripts/widgets/widgets.js"
    ],
    tests: [
        "spec/javascript/*Test.js"
    ]
};