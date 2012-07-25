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
      formatter: function() {
          return '<b>'+ this.series.name +'</b><br/>'+
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
  });
};

function RepresentativeSorter () {
  this.districts = {};
  this.parties   = {};
  this.all       = [];
}

RepresentativeSorter.prototype.init = function() {
  var self = this;

  $("#sort-representatives").bind('change', function() {
    var val = $(this).val();
    if(val === 'district') {
      self.sortByDistrict();
    } else if (val === 'name')  {
      self.sortByName();
    } else {
      self.sortByParty();
    }
  })

  // extract data
  $('.representatives-list .representative').each(function() {
    var $e = $(this);
    self.all.push($e);

    var districtSlug = $e.data('district');
    var partySlug = $e.data('party');

    var district = self.districts[districtSlug] = self.districts[districtSlug] || {};
    var party = self.parties[partySlug] = self.parties[partySlug] || {};

    district.name = district.name || $e.find('.region').first().text();
    district.representatives = district.representatives || [];

    party.name = party.name || $e.find('.org').first().text();
    party.representatives = party.representatives || [];

    district.representatives.push($e);
    party.representatives.push($e);
  });
};

RepresentativeSorter.prototype.sortByDistrict = function() {
  var districtKey,
      sortedDomElements = $('<div class="wrapper" />'),
      heading,
      list;

  for (districtKey in this.districts) {
    if(this.districts.hasOwnProperty(districtKey)) {
      heading = $('<h2 class="representatives-sort-criteria-heading" />');
      heading.text(this.districts[districtKey].name);
      heading.addClass("district-" + districtKey);
      sortedDomElements.append(heading);

      list = $('<ul class="representatives-list" />');
      list.addClass("district-" + districtKey);
      sortedDomElements.append(list);

      var reps = this.districts[districtKey].representatives;
      for (var i=0; i < reps.length; i++) { list.append(reps[i].clone()); };
    }
  }

  $('#representative-list-container').html(sortedDomElements);
};

RepresentativeSorter.prototype.sortByParty = function() {
  var partyKey,
      sortedDomElements = $('<div class="wrapper" />'),
      list;

  for (partyKey in this.parties) {
    if(this.parties.hasOwnProperty(partyKey)) {
      heading = $('<h2 class="representatives-sort-criteria-heading" />');
      heading.text(this.parties[partyKey].name);
      heading.addClass("party-" + partyKey);
      sortedDomElements.append(heading);

      list = $('<ul class="representatives-list" />');
      list.addClass("party-" + partyKey);
      sortedDomElements.append(list);

      var reps = this.parties[partyKey].representatives;
      for (var i=0; i < reps.length; i++) { list.append(reps[i].clone()); };
    }
  }

  $('#representative-list-container').html(sortedDomElements);
};

RepresentativeSorter.prototype.sortByName = function() {
  var sortedDomElements = $('<div class="wrapper" />');

  list = $('<ul class="representatives-list" />');
  sortedDomElements.append(list);

  $.each(this.all, function() {
    list.append(this.clone());
  });

  $('#representative-list-container').html(sortedDomElements);
};
