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

    describe "with some real timestamp data" do
      before do
        @first_cluster_timestamps = [
          '2012-06-12 09:13:07 UTC',
          '2012-06-12 09:13:13 UTC',
          '2012-06-12 09:13:55 UTC',
          '2012-06-12 09:13:55 UTC',
          '2012-06-12 09:14:20 UTC',
          '2012-06-12 09:14:39 UTC',
          '2012-06-12 09:14:50 UTC',
          '2012-06-12 09:15:39 UTC',
          '2012-06-12 09:15:39 UTC',
          '2012-06-12 09:16:35 UTC',
          '2012-06-12 09:16:57 UTC',
          '2012-06-12 09:17:14 UTC',
          '2012-06-12 09:17:30 UTC',
          '2012-06-12 09:17:47 UTC',
          '2012-06-12 09:18:06 UTC',
          '2012-06-12 09:18:21 UTC',
          '2012-06-12 09:18:55 UTC',
          '2012-06-12 09:18:55 UTC',
          '2012-06-12 09:19:18 UTC',
          '2012-06-12 09:19:37 UTC',
          '2012-06-12 09:19:52 UTC',
          '2012-06-12 09:20:01 UTC'
        ].map { |e| Time.parse(e).to_i }

        @second_cluster_timestamps = [
          '2012-06-12 17:54:37 UTC',
          '2012-06-12 17:54:52 UTC',
          '2012-06-12 17:55:27 UTC',
          '2012-06-12 17:55:43 UTC',
          '2012-06-12 17:55:57 UTC',
          '2012-06-12 17:56:44 UTC',
          '2012-06-12 17:56:44 UTC',
          '2012-06-12 17:56:58 UTC',
          '2012-06-12 17:57:46 UTC',
          '2012-06-12 17:57:46 UTC',
          '2012-06-12 17:58:39 UTC',
          '2012-06-12 17:58:39 UTC',
          '2012-06-12 17:59:27 UTC',
          '2012-06-12 17:59:27 UTC',
          '2012-06-12 17:59:58 UTC',
          '2012-06-12 18:00:40 UTC',
          '2012-06-12 18:00:40 UTC',
          '2012-06-12 18:01:09 UTC',
          '2012-06-12 18:01:09 UTC',
          '2012-06-12 18:01:39 UTC',
          '2012-06-12 18:02:04 UTC',
          '2012-06-12 18:02:04 UTC',
          '2012-06-12 18:02:37 UTC',
          '2012-06-12 18:02:37 UTC'
          ].map { |e| Time.parse(e).to_i }

          timestamps = [@first_cluster_timestamps,
            @second_cluster_timestamps].flatten

          @clusterer = OneDimentionalHierarchicalClusterer.new(timestamps, 900)
      end

      it "should have two clusters" do
        @clusterer.clusters.count.should eq 2
      end

      it "should have the earliest timestamps in the first cluster" do
        @clusterer.clusters.sort.first.sort.should eq @first_cluster_timestamps.sort
      end

      it "should put the second cluster in the second cluster (duh)" do
        @clusterer.clusters.sort[1].sort.should eq @second_cluster_timestamps.sort
      end

    end

  end
end
