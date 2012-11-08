define(["prettyprint"], function (prettyPrintOne) {
  return function (element) {
    element.innerHTML = prettyPrintOne(element.innerHTML);
  };
});