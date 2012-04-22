// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function PresenceStatsGraph(selector, options) {
  this.selector = selector;
  this.options = options;
}

PresenceStatsGraph.prototype.render = function() {
  this.chart = new Highcharts.Chart({
    chart: {
      renderTo: this.selector,
      type: 'area',
      backgroundColor: null,
      marginBottom: 100
    },
    credits: {
      text: this.options.credits
    },
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
        text: 'Prosent tilstede'
      },
      min: 0,
      max: 100
    },
    tooltip: {
      formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          Highcharts.dateFormat('%Y-%m-%d: ', this.x) + this.y;
      }
    },
    plotOptions: {
      area: {
        marker: {
          enabled: false,
          states: { hover: { enabled: true } }
        }
      }
    },
    series: this.options.series
  });
};

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
    credits: {
      text: this.options.credits
    },
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
      labels: { enabled: false},
      title: {
        text: ''
      },
    },
    tooltip: {
      formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
          Highcharts.dateFormat('%Y-%m-%d: ', this.x) + this.y;
      }
    },
    plotOptions: {
      area: {
        marker: {
          enabled: false,
          states: { hover: { enabled: true } }
        }
      }
    },
    series: this.options.series
  });
};

