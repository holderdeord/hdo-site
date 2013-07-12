require 'socket'

module Hdo
  module Utils

    #
    # Report some stats to Graphite.
    # Intended to be run from cron or background process.
    #

    class GraphiteReporter

      DEFAULT_HOST = 'ops1.holderdeord.no'
      DEFAULT_PORT = 2003

      def self.instance
        @instance ||= new
      end

      def initialize(opts = {})
        @host  = opts[:host] || DEFAULT_HOST
        @port  = opts[:port] || DEFAULT_PORT
        @debug = !!opts[:debug]
        @log   = Logger.new(STDOUT)

        reset
      end

      def add(key, value)
        @data[key] = value
      end

      def reset
        @data = {}
      end

      def submit
        ts    = Time.now.to_i
        lines = @data.map { |k, v| "#{k} #{v} #{ts}" }

        if @debug
          lines.each { |l| @log.info l }
        else
          io = TCPSocket.new(@host, @port.to_i)

          begin
            lines.each { |l| io.puts l}
          ensure
            io.close unless io.closed?
          end
        end

        reset
      end

    end
  end
end
