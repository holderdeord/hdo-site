var config = module.exports;

config["HDO javascript tests"] = {
    rootPath: "../",
    environment: "browser",
    libs: [
        "tmp/buster/require-conf.js",
        "tmp/buster/require.js",
        "tmp/buster/**/*.js"
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