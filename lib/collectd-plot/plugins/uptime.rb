

module CollectdPlot
  module Plugins
    module Uptime
      def self.massage_graph_opts!(opts)
        opts[:title] = "uptime"
        opts[:ylabel] = 'days'
        opts[:series] = {
          'current' => {:rrd => 'uptime', :value => 'value'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%.1lf'
      end

      def self.types(instance = nil)
        ['uptime']
      end
    end
  end
end
