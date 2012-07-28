/* global HDO, Highcharts */

(function (HDO, Highcharts) {

  HDO.topicSupportGraph = {
    create: function (selector, data) {
      var instance = Object.create(this);
      instance.selector = selector;
      instance.data = data;
      return instance;
    },

    categories: function () {
      return $.map(this.data, function (entry) { return entry[0]; });
    },

    series: function () {
      var result = {data: []}, i, entry;

      for (i = 0; i < this.data.length; i++) {
        entry = this.data[i];
        result.data.push(entry[1]);
      }

      return [result];
    },

    render: function () {
      var chart = {
        chart: {
          renderTo: this.selector,
          type: 'bar'
        },
        credits: {
          text: 'holderdeord.no'
        },
        title: {
          text: ''
        },
        xAxis: {
          categories: this.categories(),
          title: {
            text: null
          }
        },
        yAxis: {
          min: 0,
          title: {
            text: 'Prosent voteringer',
            align: 'high'
          },
          labels: {
            enabled: false,
            overflow: 'justify'
          }
        },
        tooltip: {
          formatter: function () {
            return this.x + ': ' + this.y + '%';
          }
        },
        plotOptions: {
          bar: {
            dataLabels: {
              enabled: true
            },
            colorByPoint: true
          }
        },
        series: this.series()
      };

      this.chart = new Highcharts.Chart(chart);
    }
  };

}(HDO, Highcharts));
