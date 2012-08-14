require 'spec_helper'
require 'time'

module Hdo
  describe OneDimentionalHierarchicalClusterer do
    describe "basic private distance calculators" do
      before do
        @clusterer = OneDimentionalHierarchicalClusterer.new([1,2],0)
      end

      it "knows the distance between two points" do
        @clusterer.send(:distance_between_point_and_point, 0, 19).should eq (19**2)
      end

      it "knows the minimum distance between an array and a point" do
        @clusterer.send(:distance_between_array_and_point, [1,10], 11).should eq 1
      end

      it "knows the minimum distance between two arrays" do
        @clusterer.send(:distance_between_array_and_array, [1,10], [11, 5]).should eq 1
      end

      it "finds key of min value in hash" do
        hash = {}
        hash[:one] = 1
        hash[:twelve] = 12
        hash[:twenty] = 20

        @clusterer.send(:find_key_of_min_value_in, hash).should eq :one
      end
    end
  end
end
