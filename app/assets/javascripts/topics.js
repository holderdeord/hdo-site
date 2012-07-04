// =====================
// = TopicSupportGraph =
// =====================

function TopicSupportGraph(selector, data) {
  this.selector = selector;
  this.data = data;
}

TopicSupportGraph.prototype.categories = function() {
  return $.map(this.data, function(entry) { return entry[0]; })
};

TopicSupportGraph.prototype.series = function() {
  var result = {data: []};

  for (var i=0; i < this.data.length; i++) {
    var entry = this.data[i]
    result.data.push(entry[1]);
  };

  return [result];
};


TopicSupportGraph.prototype.render = function() {
  this.chart = new Highcharts.Chart({
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
      formatter: function() {
        console.log(this);
        return ''+
          this.x +': '+ this.y +'%';
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
  });

  return this;
};

// =====================
// = TopicVoteSelector =
// =====================

function TopicVoteSelector(topicId) {
  this.topicId = topicId;
}

TopicVoteSelector.prototype.init = function() {
  this.spinner = $("#spinner");
  this.container = $("#vote-selector");
  this.searchField = $("#vote-search");

  this.bind();
};

TopicVoteSelector.prototype.bind = function() {
  var self = this;

  self.searchField.blur(function(e) {
    self.loadSearchResult();
  });
};

TopicVoteSelector.prototype.loadSearchResult = function() {
  var filter = this.searchField.val();

  this.container.html('');

  if (filter === '')
    return;

  this.container.html('');
  this.spinner.show();

  var self = this;

  $.ajax({
    url: '/topics/' + this.topicId + '/edit/votes/search',
    type: "GET",
    dataType: "html",
    data: $.param({
      query: filter
    }),

    success: function(html) {
      self.spinner.hide();
      self.container.html(html);
    },

    error: function() {
      console.log(arguments);
    },
  });
};
