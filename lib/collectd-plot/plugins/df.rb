

module CollectdPlot
  module Plugins
    module Df
      def self.massage_graph_opts!(opts)
        opts[:title] = "disk space (#{opts[:instance]})"
        opts[:ylabel] = 'bytes'
        opts[:series] = {
          'reserved' => {:rrd => 'df_complex-reserved', :value => 'value'},
          'free    ' => {:rrd => 'df_complex-free', :value => 'value'},
          'used    ' => {:rrd => 'df_complex-used', :value => 'value'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :stacked
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types(instance = nil)
        ['df_complex']
      end
    end
  end
end
