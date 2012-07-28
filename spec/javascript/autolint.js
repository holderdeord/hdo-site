module.exports = {
  paths: [ "../../app/assets/javascripts/*.js" ],   // a list of paths to the files you want linted
  linter: "jslint",         // optionally: jshint
  linterOptions: {          // see default-configuration.js for a list of all options
    browser: true,
    sloppy: true,
    nomen: true,
    maxlen: 120,
    indent: 2,
    plusplus: true,
    predef: ["HDO", "jQuery", "$", "_", "Highcharts"]              // a list of known global variables
  },
  excludes: []              // a list of strings/regexes matching filenames that should not be linted
};
