/* global HDO, Highcharts */

(function (HDO, Highcharts) {

  HDO.presenceStatsGraph = {
    create: function (selector, options) {
      var instance = Object.create(this);
      instance.selector = selector;
      instance.options = options;
      return instance;
    },

    render: function () {
      var chart = {
        chart: {
          renderTo: this.selector,
          type: 'area',
          backgroundColor: null
        },
        credits: {
          text: this.options.credits
        },
        legend: {
          enabled: false
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
          formatter: function () {
            return '<b>' + this.series.name + '</b><br/>' +
              Highcharts.dateFormat('%Y-%m-%d: ', this.x) + this.y;
          }
        },
        plotOptions: {
          area: {
            lineWidth: 1,
            marker: {
              enabled: false,
              states: { hover: { enabled: true } }
            }
          }
        },
        series: this.options.series
      };

      this.chart = new Highcharts.Chart(chart);
    }
  };
}(HDO, Highcharts));

