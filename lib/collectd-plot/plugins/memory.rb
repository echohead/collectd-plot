

module CollectdPlot
  module Plugins
    module Memory
      def self.massage_graph_opts!(opts)
        opts[:title] = 'memory utilization'
        opts[:ylabel] = 'bytes'
        opts[:series] = {
          'free    ' => {:rrd => 'memory-free', :value => 'value'},
          'buffered' => {:rrd => 'memory-buffered', :value => 'value'},
          'cached  ' => {:rrd => 'memory-cached', :value => 'value'},
          'used    ' => {:rrd => 'memory-used', :value => 'value'}
        }
        opts[:line_width] = 2
        opts[:graph_type] = :stacked
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types()
        ['memory']
      end
    end
  end
end
