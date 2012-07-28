// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function VoteChart (selector, data) {
  this.selector = selector;
  this.data = data;
}

VoteChart.prototype.render = function() {
  this.chart = new Highcharts.Chart({
    chart: {
      renderTo: this.selector,
      type: 'column',
      backgroundColor: null
    },
    credits: {
      text: 'holderdeord.no',
    },
    title: {
      text: ' '
    },
    xAxis: {
      categories: ['For', 'Mot', 'Ikke tilstede']
    },
    yAxis: {
      min: 0,
      title: {
        text: 'Antall representanter'
      },
    },
    legend: {
      enabled: false,
    },
    tooltip: {
      formatter: function() {
        return '<b>'+ this.x +'</b><br/>'+
          this.series.name +': '+ this.y +'<br/>'
      }
    },
    plotOptions: {
      column: {
        colorByPoint: true,
        stacking: 'normal',
        dataLabels: {
          enabled: true,
          color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
        }
      }
    },
    series: [{
      data: [
        { y: this.data.for,     color: '#89A54E' },
        { y: this.data.against, color: '#AA4643'},
        { y: this.data.absent,  color: 'gray'}
      ]
    }]
  });
};

