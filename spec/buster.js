var config = module.exports;

config["HDO javascript tests"] = {
    rootPath: "../",
    environment: "browser",
    libs: [
        "spec/javascript/lib/require-conf.js",
        "spec/javascript/lib/require.js",
        "spec/javascript/lib/jquery-1.7.2.min.js",
        "spec/javascript/lib/bootstrap.js"
    ],
    sources: [
        "app/assets/javascripts/hdo/lazyLoadCarouselImages.js",
        "app/assets/javascripts/hdo/representativeSearch.js",
        "app/assets/javascripts/hdo/promises.js"
    ],
    tests: [
        "spec/javascript/**/*Test.js"
    ],
    extensions: [require("buster-amd")]
};