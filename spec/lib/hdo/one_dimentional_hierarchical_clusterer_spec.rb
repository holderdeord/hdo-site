require 'spec_helper'
require 'time'

module Hdo
  describe OneDimentionalHierarchicalClusterer do
    describe "basic private distance calculators" do
      before do
        @clusterer = OneDimentionalHierarchicalClusterer.new([1,2],1)
      end

      it "knows the distance between two points" do
        @clusterer.send(:distance_between_point_and_point, 0, 19).should eq (19)
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
        distances[[0,1]].should eq 2
        distances[[0,2]].should eq 5
        distances[[1,2]].should eq 3

        # for clusters and points
        clusters_with_clusters = [[0, 1], 5, [10,11]]
        distances = @clusterer.send(:distances_matrix_for, clusters_with_clusters)
        distances.count.should eq 3
        distances[[0,1]].should eq 4
        distances[[0,2]].should eq 9
        distances[[1,2]].should eq 5
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
        distance, clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 2
        clusters.last.should eq [1,2]
        clusters[0].should eq 4

        distance.should eq 1
      end

      it "pairs nearest point and cluster" do
        points = [1, [10,11], 99, [100,101]]
        distance, clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 3
        clusters.last.should eq [99,100,101]
        distance.should eq 1
      end

      it "pairs nearest two clusters" do
        points = [1, [10,11], [13,15], 20, [100,101]]
        distance, clusters = @clusterer.send(:pair_nearest_in, points)

        clusters.count.should eq 4
        clusters.last.should eq [10,11,13,15]
        distance.should eq 2
      end
    end

    describe "with separation 2" do
      points = [1,2,5,6,9,10]
      before do
        @clusterer = OneDimentionalHierarchicalClusterer.new(points,2)
      end

      it "should have 3 clusters" do
        @clusterer.clusters.count.should eq 3
      end

      it "should have [1,2] in a cluster" do
        @clusterer.clusters.should include [1,2]
      end

      it "should have [5,6] in a cluster" do
        @clusterer.clusters.should include [5,6]
      end

      it "should have [9,10] in a cluster" do
        @clusterer.clusters.should include [9,10]
      end

    end

    it "should cluster some real timestamp data" do
      points = [1339524157, 1339524157, 1339523967, 1339523967, 1339523998, 1339524040, 1339524040, 1339492435, 1339492435, 1339492460, 1339492479, 1339492490, 1339524069, 1339524069, 1339492595, 1339492617, 1339492634, 1339492650, 1339492667, 1339492686, 1339492701, 1339492735, 1339492735, 1339492758, 1339492777, 1339492792, 1339492801, 1339524099, 1339524124, 1339524124, 1339523804, 1339523804, 1339523866, 1339523866, 1339523818, 1339492387, 1339492393, 1339523727, 1339523743, 1339523757, 1339492539, 1339492539, 1339523677, 1339523692, 1339523919, 1339523919]
      clusterer = OneDimentionalHierarchicalClusterer.new(points,900)
    end

  end
end
