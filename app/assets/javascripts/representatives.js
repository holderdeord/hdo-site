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

var HDO = HDO || {};
HDO.representatives = HDO.representatives || {};

$(document).ready(function(){
  var district_regex = /.*(district-[^ \t]+).*/,
      party_regex = /.*(party-[^ \t]+).*/,
      sort_by_district_link = $('<a />'),
      sort_by_party_link = $('<a />');

  HDO.representatives.districts = {};
  HDO.representatives.parties = {};

  sort_by_district_link.text(HDO.representatives.sortByDistrictText);
  sort_by_party_link.text(HDO.representatives.sortByPartyText);

  $('.page-header').append(sort_by_district_link);
  $('.page-header').append(sort_by_party_link);

  $('.representatives-list .representative').each(function(index, element) {
    var $e, classes, district, party, district_class, party_class, regex_result;
    $e = $(element);
    classes = $e.attr('class');
    regex_result = district_regex.exec(classes);
    district_class = regex_result[1];
    district = HDO.representatives.districts[district_class] = HDO.representatives.districts[district_class] || {};
    district.name = district.name || $e.find('.region').first().text();
    district.representatives = district.representatives || [];
    district.representatives.push($e);

    regex_result = party_regex.exec(classes);
    party_class = regex_result[1];
    party = HDO.representatives.parties[party_class] = HDO.representatives.parties[party_class] || {};
    party.name = party.name || $e.find('.org').first().text();
    party.representatives = party.representatives || [];
    party.representatives.push($e);
  });

  HDO.representatives.sortByDistrict = function() {
    var districts = HDO.representatives.districts,
                    district_key,
                    sorted_dom_elements = $('<div class="wrapper" />'),
                    heading,
                    list,
                    i, j;

    for (district_key in districts) {
      if(districts.hasOwnProperty(district_key)) {
        heading = $('<h2 class="representatives-sort-criteria-heading" />');
        heading.text(districts[district_key].name);
        heading.addClass(district_key);
        sorted_dom_elements.append(heading);

        list = $('<ul class="representatives-list" />');
        list.addClass(district_key);
        sorted_dom_elements.append(list);
        for (i = 0, j = districts[district_key].representatives.length; i < j; i += 1) {
          list.append(districts[district_key].representatives[i].clone());
        }
      }
    }

    $('.representatives-list').remove();
    $('.page-header').after(sorted_dom_elements);
  };

  HDO.representatives.sortByParty = function() {
    var parties = HDO.representatives.parties,
                    party_key,
                    sorted_dom_elements = $('<div class="wrapper" />'),
                    list,
                    i, j;

    for (party_key in parties) {
      if(parties.hasOwnProperty(party_key)) {

        heading = $('<h2 class="representatives-sort-criteria-heading" />');
        heading.text(parties[party_key].name);
        heading.addClass(party_key);
        sorted_dom_elements.append(heading);

        list = $('<ul class="representatives-list" />');
        list.addClass(party_key);
        sorted_dom_elements.append(list);

        for (i = 0, j = parties[party_key].representatives.length; i < j; i += 1) {
          list.append(parties[party_key].representatives[i].clone());
        }
      }
    }

    $('.representatives-list').remove();
    $('.representatives-sort-criteria-heading').remove();
    $('.page-header').after(sorted_dom_elements);
  };

  sort_by_district_link.bind('click', HDO.representatives.sortByDistrict);
  sort_by_party_link.bind('click', HDO.representatives.sortByParty);
});

