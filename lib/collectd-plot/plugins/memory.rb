

module CollectdPlot
  module Plugins
    module Memory
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = 'memory utilization'
          res[:ylabel] = 'bytes'
          res[:series] = {
            'free    ' => {:rrd => 'memory-free', :value => 'value'},
            'buffered' => {:rrd => 'memory-buffered', :value => 'value'},
            'cached  ' => {:rrd => 'memory-cached', :value => 'value'},
            'used    ' => {:rrd => 'memory-used', :value => 'value'}
          }
          res[:line_width] = 2
          res[:graph_type] = :stacked
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['memory']
      end
    end
  end
end
