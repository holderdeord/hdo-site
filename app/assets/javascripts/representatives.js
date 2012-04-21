// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function VoteStatsGraph(selector, options) {
  this.selector = selector;
  this.options = options;
}

VoteStatsGraph.prototype.render = function() {
  this.chart = new Highcharts.Chart({
    chart: {
      renderTo: this.selector,
      type: 'spline',
      backgroundColor: null
    },
    credits: { enabled: false },
    title: {
      text: this.options.title
    },
    subtitle: {
      text: this.options.subtitle
    },
    xAxis: {
      type: 'datetime',
      dateTimeLabelFormats: {
        month: '%Y-%m',
        year: '%b'
      }
    },
    yAxis: {
      title: {
        text: ''
      },
      labels: false,
      tickInterval: 1,
    },
    tooltip: {
      formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          Highcharts.dateFormat('%Y-%m-%d', this.x);
      }
    },

    series: this.options.series
  });
};

