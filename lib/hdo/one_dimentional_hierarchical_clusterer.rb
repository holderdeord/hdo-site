module Hdo
  class OneDimentionalHierarchicalClusterer
    attr_reader :clusters

    def initialize(points, separation)
      @points = points
      @separation = separation
      @clusters = calculate_clustering
    end

    private

    def calculate_clustering
      @clusters = @points
      # min_distance = find_key_of_min_value_in distances_matrix
    end

    def find_key_of_min_value_in(hash)
      min_key = nil
      hash.each do |k,v|
        min_key = k if hash[min_key] == nil || v < hash[min_key]
      end
      min_key
    end

    def distances_matrix
      distances = Hash.new
      @clusters.each_with_index do |cluster, i|
        @clusters.each do |other, j|
          if cluster != other
            distances[[i,j]] = distance_between cluster,other
          end
        end
      end
      distances
    end

    def distance_between(cluster,other)
      if Array === cluster
        if Array === other
          distance_betwee_array_and_array cluster, other
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
      (a - b) ** 2
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