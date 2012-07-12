module.exports = {
    paths: [ "../../app/assets/javascripts/*.js" ],   // a list of paths to the files you want linted
    linter: "jslint",         // optionally: jshint
    linterOptions: {          // see default-configuration.js for a list of all options
        browser: true,
        sloppy: true,
        nomen: true,
        maxlen: 120,
        predef: ["HDO", "jQuery", "$", "_"]              // a list of known global variables
    },
    excludes: []              // a list of strings/regexes matching filenames that should not be linted
};
