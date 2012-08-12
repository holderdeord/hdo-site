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
  end

end