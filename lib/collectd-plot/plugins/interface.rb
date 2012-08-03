

module CollectdPlot
  module Plugins
    module Interface

      def self.massage_graph_opts(opts)
        {}.tap do |res|
          case opts[:type]
          when 'if_errors'
            res[:title] = "interface errors (#{opts[:instance]})"
            res[:ylabel] = 'errors/s'
          when 'if_octets'
            res[:title] = "interface traffic (#{opts[:instance]})"
            res[:ylabel] = 'bytes/s'
          when 'if_packets'
            res[:title] = "interface packets (#{opts[:instance]})"
            res[:ylabel] = 'packets/s'
          else raise "unknown type: #{opts[:type]}"
          end

          res[:series] = {
            'receive'  => {:rrd => opts[:type], :value => 'rx'},
            'transmit' => {:rrd => opts[:type], :value => 'tx'}
          }
          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['if_errors', 'if_packets', 'if_octets']
      end
    end
  end
end
