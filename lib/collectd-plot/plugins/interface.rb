

module CollectdPlot
  module Plugins
    module Interface

      def self.massage_graph_opts!(opts)
        case opts[:type]
        when 'if_errors'
          opts[:title] = "interface errors (#{opts[:instance]})"
          opts[:ylabel] = 'errors/s'
        when 'if_octets'
          opts[:title] = "interface traffic (#{opts[:instance]})"
          opts[:ylabel] = 'bytes/s'
        when 'if_packets'
          opts[:title] = "interface packets (#{opts[:instance]})"
          opts[:ylabel] = 'packets/s'
        else raise "unknown type: #{opts[:type]}"
        end

        opts[:series] = {
          'receive'  => {:rrd => opts[:type], :value => 'rx'},
          'transmit' => {:rrd => opts[:type], :value => 'tx'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types(instance = nil)
        ['if_errors', 'if_packets', 'if_octets']
      end
    end
  end
end
