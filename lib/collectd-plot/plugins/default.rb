

module CollectdPlot
  module Plugins
    module Default
      def self.massage_graph_opts!(opts)
        opts[:title] = "#{opts[:metric]}-#{opts[:instance]}"
        opts[:series] = {
          opts[:instance] => {:rrd => opts[:instance], :value => 'value'}
        }
        opts[:line_width] = 2
        opts[:graph_type] = :line
        opts[:rrd_format] = '%.2lf'
      end

      def self.types()
        []
      end
    end
  end
end
