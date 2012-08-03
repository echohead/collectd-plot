

module CollectdPlot
  module Plugins
    module Disk

      def self.massage_graph_opts(opts)
        {}.tap do |res|
          case opts[:type]
          when 'disk_merged'
            res[:title] = "disk merged operations (#{opts[:instance]})"
            res[:ylabel] = 'merged operations per second'
          when 'disk_octets'
            res[:title] = "disk traffic (#{opts[:instance]})"
            res[:ylabel] = 'bytes per second'
          when 'disk_ops'
            res[:title] = "disk ops per second (#{opts[:instance]})"
            res[:ylabel] = 'ops per second'
          when 'disk_time'
            res[:title] = "disk time per operation (#{opts[:instance]})"
            res[:ylabel] = 'average time per op'
          else raise "unknown type: #{opts[:type]}"
          end

          res[:series] = {
            'read'  => {:rrd => opts[:type], :value => 'read'},
            'write' => {:rrd => opts[:type], :value => 'write'}
          }
          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['disk_merged', 'disk_octets', 'disk_ops', 'disk_time']
      end
    end
  end
end
