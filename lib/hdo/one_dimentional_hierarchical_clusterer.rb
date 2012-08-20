module Hdo
  class OneDimentionalHierarchicalClusterer
    attr_reader :clusters

    def initialize(points, separation)
      @points = points
      @separation = separation
      calculate_clustering
    end

    private

    def calculate_clustering
      @clusters = @points
      min_distance, closest_pair = find_key_of_min_value_in distances_matrix_for @clusters

      while min_distance < @separation && @separation != 0
        min_distance, clusters = pair_nearest_in @clusters.dup
        @clusters = clusters if min_distance < @separation
      end
    end

    def pair_nearest_in(clusters)
      distance, nearest_pair_indices = find_key_of_min_value_in distances_matrix_for clusters
      new_cluster = clusters.select do |p|
        p == clusters[nearest_pair_indices[0]] or p == clusters[nearest_pair_indices[1]]
      end

      clusters.delete_at clusters.index new_cluster[0]
      clusters.delete_at clusters.index new_cluster[1]

      [distance, clusters << new_cluster.flatten]
    end

    def find_key_of_min_value_in(hash)
      min_key = nil
      hash.each do |k,v|
        min_key = k if hash[min_key] == nil || v < hash[min_key]
      end
      [hash[min_key], min_key]
    end

    def distances_matrix_for(clusters)
      distances = Hash.new
      clusters.each_with_index do |cluster, i|
        clusters[(i+1)..-1].each_with_index do |other, j|
          distances[[i,j+i+1]] = distance_between cluster,other
        end
      end
      distances
    end

    def distance_between(cluster,other)
      if Array === cluster
        if Array === other
          distance_between_array_and_array cluster, other
        else
          distance_between_array_and_point cluster, other
        end
      else
        if Array === other
          distance_between_array_and_point other, cluster
        else
          distance_between_point_and_point other, cluster
        end
      end
    end

    def distance_between_point_and_point(a,b)
      Math.sqrt((a - b) ** 2)
    end

    def distance_between_array_and_point(array, point)
      array.inject(Float::INFINITY) do |min_distance, array_point|
        d = distance_between_point_and_point point, array_point
        d < min_distance ? d : min_distance
      end
    end

    def distance_between_array_and_array(array, other)
      array.inject(Float::INFINITY) do |min_distance, array_point|
        d = distance_between_array_and_point other, array_point
        d < min_distance ? d : min_distance
      end
    end

  end
end