module.exports = {
  paths: [ "../app/assets/javascripts/*.js" ],
  linter: "jslint",
  linterOptions: {
    browser: true,
    sloppy: true,
    nomen: true,
    maxlen: 120,
    indent: 2,
    plusplus: true,
    predef: ["HDO", "jQuery", "$", "_", "Highcharts"] // globals
  },
  excludes: ["../app/assets/javascripts/lib/*.js"]
};
