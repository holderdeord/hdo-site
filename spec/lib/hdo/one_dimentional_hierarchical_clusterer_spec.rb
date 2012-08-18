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

      it "calculates a distance matrix" do
        # for points
        clusters = [0,2,5]
        distances = @clusterer.send(:distances_matrix_for, clusters)
        distances.count.should eq 3
        distances[[0,1]].should eq 4
        distances[[0,2]].should eq 25
        distances[[1,2]].should eq 9

        # for clusters and points
        clusters_with_clusters = [[0, 1], 5, [10,11]]
        distances = @clusterer.send(:distances_matrix_for, clusters_with_clusters)
        distances.count.should eq 3
        distances[[0,1]].should eq 16
        distances[[0,2]].should eq 9**2
        distances[[1,2]].should eq 25
      end

      it "finds key of min value in hash" do
        hash = {}
        hash[:one] = 1
        hash[:twelve] = 12
        hash[:twenty] = 20

        @clusterer.send(:find_key_of_min_value_in, hash).should eq [1, :one]
      end

      it "pairs nearest two points" do
        points = [1,2,4]
        clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 2
        clusters.last.should eq [1,2]
        clusters[0].should eq 4
      end

      it "pairs nearest point and cluster" do
        points = [1, [10,11], 99, [100,101]]
        clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 3
        clusters.last.should eq [99,100,101]
      end

      it "pairs nearest two clusters" do
        points = [1, [10,11], [12,13], 20, [100,101]]
        clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 4
        clusters.last.should eq [10,11,12,13]
      end

    end
  end
end
