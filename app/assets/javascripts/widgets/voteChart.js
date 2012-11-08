define(["require", "hdo/voteChart"], function (require, voteChart) {
  return function (container) {
    var chartData = require("chartData"),
      chart = voteChart.create(container.id, chartData);
    chart.render();
  };
});