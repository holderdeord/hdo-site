// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function ForAgainstChart (selector, data) {
  this.selector = selector;
  this.data = data;
}

ForAgainstChart.prototype.render = function() {
  this.chart = new Highcharts.Chart({
    chart: {
      renderTo: this.selector,
      backgroundColor: null,
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false
    },
    colors: ['#89A54E', '#AA4643'],
    title: {
      // TODO: i18n
      text: 'Stemmer'
    },
    credits: {
      // TODO: get this through i18n
      text: 'holderdeord.no'
    },
    tooltip: {
      formatter: function() {
        return '<b>'+ this.point.name +'</b>: '+ this.point.y +' %';
      }
    },
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: true,
          color: '#000000',
          connectorColor: '#000000',
          formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ this.point.y +' %';
          }
        }
      }
    },
    series: [{
      type: 'pie',
      data: this.data
    }]
  });
};

function ForAgainstChart (selector, data) {
  this.selector = selector;
  this.data = data;
}
