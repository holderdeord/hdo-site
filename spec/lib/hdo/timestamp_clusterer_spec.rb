require 'spec_helper'
require 'time'

module Hdo
  describe TimestampClusterer do
    describe "with one timestamp" do
      before do
        @timestamp = Time.now
        timestamps = [@timestamp]
        @clusterer = TimestampClusterer.new(timestamps)
      end

      it 'should return one cluster' do
        @clusterer.clusters.count.should eq 1
      end

      it "should have only one timestamp in the cluster" do
        @clusterer.clusters.first.count.should eq 1
      end

      it "should have the timestamp in the cluster" do
        @clusterer.clusters.first.first.to_i.should == @timestamp.to_i
      end
    end

    describe "with two timestamps closer than threshold" do
      before do
        @timestamps = [Time.parse('2012-01-01 10:00:00'), Time.parse('2012-01-01 09:59:00')]
        @threshold = 900
        @clusterer = TimestampClusterer.new(@timestamps, @threshold)
      end

      it "should return one cluster" do
        @clusterer.clusters.count.should eq 1
      end

      it "should have two timestamps in the cluster" do
        @clusterer.clusters.first.count.should eq 2
      end
    end

    describe "with two timestamps further apart than the threshold" do
      before do
        @timestamps = [Time.parse('2012-01-01 10:00:00'), Time.parse('2012-01-01 09:00:00')]
        @threshold = 900
        @clusterer = TimestampClusterer.new(@timestamps, @threshold)
      end

      it "should return two clusters" do
        @clusterer.clusters.count.should eq 2
      end

      it "should have different timestamps in each cluster" do
        @clusterer.clusters[0].first.to_i.should_not eq @clusterer.clusters[1].first.to_i
      end
    end

    describe "with five timestamps that are all far apart" do
      before do
        @timestamps = [Time.parse('2012-01-01 09:00:00'),
          Time.parse('2012-01-01 10:00:00'),
          Time.parse('2012-01-01 11:00:00'),
          Time.parse('2012-01-01 12:00:00'),
          Time.parse('2012-01-01 13:00:00')]
        @threshold = 900
        @clusterer = TimestampClusterer.new(@timestamps, @threshold)
      end

      it "should return five clusters" do
        @clusterer.clusters.count.should eq 5
      end

      it "should know which cluster a timestamp is the closest to" do
        t = Time.parse '2012-01-01 11:14:00'
        nearest_cluster = @clusterer.nearest_cluster_for t
        nearest_cluster.first.to_i.should == @timestamps[2].to_i
      end
    end

    describe "with three timestamps where two are close and one is far" do
      before do
        @timestamps = [Time.parse('2012-01-01 09:00:00'),
          Time.parse('2012-01-01 09:14:00'),
          Time.parse('2012-01-01 11:00:00')]
        @threshold = 900
        @clusterer = TimestampClusterer.new(@timestamps, @threshold)
      end

      it "should have two clusters" do
        @clusterer.clusters.count.should eq 2
      end

      it "should group the two early timestamps together" do
        @clusterer.clusters.sort.first.count.should == 2
        @clusterer.clusters.sort.first.first.to_i.should == Time.parse('2012-01-01 09:00:00').to_i
      end

      it "should put the late timestamp in its own cluster" do
        @clusterer.clusters.sort[1].count.should == 1
        @clusterer.clusters.sort[1].first.to_i.should == @timestamps[2].to_i
      end
    end

    describe "with 8 timestamps of different distances" do
      # before do
      #   @first_cluster = [Time.parse('2012-01-01 09:00:00'),
      #     Time.parse('2012-01-01 09:14:00'),
      #     Time.parse('2012-01-01 09:23:00'),
      #     Time.parse('2012-01-01 09:37:00')]

      #   @second_cluster = [Time.parse('2012-01-01 09:52:00'),
      #     Time.parse('2012-01-01 10:05:00')]

      #   @third_cluster = Time.parse '2012-01-01 11:00:00'

      #   @fourth_cluster = Time.parse '2012-01-01 11:15:00'

      #   @timestamps = [@first_cluster,
      #     @second_cluster,
      #     @third_cluster,
      #     @fourth_cluster].flatten

      #   @clusterer = TimestampClusterer.new(@timestamps, 900)
      # end

      # it "should have 4 clusters" do
      #   @clusterer.clusters.count.should eq 4
      # end

      # it "should have 4 timestamps in the first cluster" do
      #   raise @clusterer.clusters.sort.inspect
      #   @clusterer.clusters.sort.first.count.should eq 4
      # end
    end
  end
end
