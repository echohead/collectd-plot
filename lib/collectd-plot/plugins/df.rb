

module CollectdPlot
  module Plugins
    module Df
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = "disk space (#{opts[:instance]})"
          res[:ylabel] = 'bytes'
          res[:series] = {
            'reserved' => {:rrd => 'df_complex-reserved', :value => 'value'},
            'free    ' => {:rrd => 'df_complex-free', :value => 'value'},
            'used    ' => {:rrd => 'df_complex-used', :value => 'value'}
          }
          res[:line_width] = 1
          res[:graph_type] = :stacked
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['df_complex']
      end
    end
  end
end
