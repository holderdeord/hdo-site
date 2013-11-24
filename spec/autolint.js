module.exports = {
  paths: [ "../app/assets/javascripts/*.js", "../app/assets/javascripts/widgets/*.js" ],
  linter: "jslint",
  linterOptions: {
    browser: true,
    sloppy: true,
    nomen: true,
    maxlen: 120,
    indent: 2,
    plusplus: true,
    predef: ["HDO", "jQuery", "$", "_", "Markdown"] // globals
  },
  excludes: ["../app/assets/javascripts/lib/*.js"]
};
