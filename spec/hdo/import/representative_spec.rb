# encoding: utf-8

require 'spec_helper'

module Hdo
  module Import
    
    describe Representative do
      it "converts external ids to query parameters" do
        Representative.query_param_from('BÅH').should == 'B_AH'
        Representative.query_param_from('ØYVH').should == '_OYVH'
        Representative.query_param_from('ØH').should == '_OH'
        Representative.query_param_from('ÆB').should == '_AEB'
      end
      
      it "converts query parameters to external ids" do
        Representative.external_id_from('B_AH').should == "BÅH"
        Representative.external_id_from('_OYVH').should == "ØYVH"
        Representative.external_id_from('_OH').should == "ØH"
        Representative.external_id_from('_AEB').should == "ÆB"
      end
    end
    
  end
end