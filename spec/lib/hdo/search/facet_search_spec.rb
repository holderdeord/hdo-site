# encoding: utf-8

require 'spec_helper'

module Hdo
  module Search
    describe FacetSearch do

      let(:params) { {} }
      let(:view_context) { double(:view_context) }
      let(:model) { double(:model) }
      let(:response) { double(:response) }

      let(:search) do
        m = model

        Class.new {
          include FacetSearch

          model m
          search_param :parliament_period, facet: {field: 'parliament_period_name', size: 20,  title: 'Periode' }

        }.new(params, view_context)
      end

      before do
        model.stub(search: response)
        view_context.stub(url_for: 'http://example.com')

        response.stub(
          page: response,
          per: response,
          results: [],
          response: {'facets' => {
              'parliament_period_name' => {
                'terms' => [
                  {'term' => '2009-2013', 'count' => 111},
                  {'term' => '2013-2017', 'count' => 222}
                ]
              }
            }
          }
        )
      end

      it 'has a JSON representation' do
        json = search.as_json
        json.keys.should == [:navigators, :results]
      end

      it 'has a keyword navigator' do
        nav = search.navigators.first
        nav.should be_keyword

        nav.title.should == 'Søk'
        nav.param.should == :q

        nav.as_json.keys.should == [:query, :title, :param, :type, :filter_url, :value]
      end

      it 'has a facet navigator' do
        nav = search.navigators.last
        nav.should be_facet

        nav.title.should == 'Periode'
        nav.param.should == :parliament_period

        nav.terms.map(&:name).should == %w[2013-2017 2009-2013]
        nav.as_json.keys.should == [:query, :title, :param, :type, :terms]
      end

    end
  end
end
