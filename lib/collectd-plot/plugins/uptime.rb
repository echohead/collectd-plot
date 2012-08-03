

module CollectdPlot
  module Plugins
    module Uptime
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = "uptime"
          res[:ylabel] = 'days'
          res[:series] = {
            'current' => {:rrd => 'uptime', :value => 'value'}
          }
          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%.1lf'
        end
      end

      def self.types(instance = nil)
        ['uptime']
      end
    end
  end
end
