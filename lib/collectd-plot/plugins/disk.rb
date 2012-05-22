

module CollectdPlot
  module Plugins
    module Disk

      def self.massage_graph_opts!(opts)
        case opts[:type]
        when 'disk_merged'
          opts[:title] = "disk merged operations (#{opts[:instance]})"
          opts[:ylabel] = 'merged operations per second'
        when 'disk_octets'
          opts[:title] = "disk traffic (#{opts[:instance]})"
          opts[:ylabel] = 'bytes per second'
        when 'disk_ops'
          opts[:title] = "disk ops per second (#{opts[:instance]})"
          opts[:ylabel] = 'ops per second'
        when 'disk_time'
          opts[:title] = "disk time per operation (#{opts[:instance]})"
          opts[:ylabel] = 'average time per op'
        else raise "unknown type: #{opts[:type]}"
        end

        opts[:series] = {
          'read'  => {:rrd => opts[:type], :value => 'read'},
          'write' => {:rrd => opts[:type], :value => 'write'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types(instance = nil)
        ['disk_merged', 'disk_octets', 'disk_ops', 'disk_time']
      end
    end
  end
end
