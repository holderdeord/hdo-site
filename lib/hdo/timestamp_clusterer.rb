require 'time'
require 'hierclust'

module Hdo
  class TimestampClusterer

    attr_reader :clusters

    def initialize(timestamps, threshold = 900)
      @timestamps = timestamps
      @threshold = threshold
      @clusters = compute_clustering
    end

    def nearest_cluster_for(timestamp)
      point = Hierclust::Point.new(timestamp.to_i, 0)
      time_in_seconds = timestamp.to_i
      min_distance = Float::INFINITY
      min_cluster = 0
      @hierclust_clusters.each_with_index do |cluster,idx|
        distance = (cluster.x - time_in_seconds)**2
        if(distance < min_distance)
          min_distance = distance
          min_cluster = idx
        end
      end
      @clusters[min_cluster]
    end

    private

    def compute_clustering
      points = @timestamps.map { |e| Hierclust::Point.new(e.to_i, 0) }
      @hierclust_clusters = Hierclust::Clusterer.new(points, @threshold).clusters
      clusters = @hierclust_clusters.map do |cluster|
        cluster.points.map { |point| Time.at(point.x) }
      end
    end
  end
end