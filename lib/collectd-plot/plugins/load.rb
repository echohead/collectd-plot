

module CollectdPlot
  module Plugins
    module Load
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = 'system load'
          res[:series] = {
            '1 min ' => {:rrd => 'load', :value => 'shortterm'},
            '5 min ' => {:rrd => 'load', :value => 'midterm'},
            '15 min' => {:rrd => 'load', :value => 'longterm'}
          }
          res[:line_width] = 1
          res[:rrd_format] = '%.2lf'
        end
      end

      def self.types(instance = nil)
        ['load']
      end
    end
  end
end
