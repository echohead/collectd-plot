

module CollectdPlot
  module Plugins
    module Default
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = "#{opts[:metric]}-#{opts[:instance]}"
          res[:series] = {
            opts[:instance] => {:rrd => opts[:instance], :value => 'value'}
          }
          res[:line_width] = 2
          res[:graph_type] = :line
          res[:rrd_format] = '%.2lf'
        end
      end

      def self.types(instance = nil)
        []
      end
    end
  end
end
