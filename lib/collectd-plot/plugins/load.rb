

module CollectdPlot
  module Plugins
    module Load
      def self.massage_graph_opts!(opts)
        opts[:title] = 'system load'
        opts[:series] = {
          '1 min ' => {:rrd => 'load', :value => 'shortterm'},
          '5 min ' => {:rrd => 'load', :value => 'midterm'},
          '15 min' => {:rrd => 'load', :value => 'longterm'}
        }
        opts[:line_width] = 1
        opts[:rrd_format] = '%.2lf'
      end

      def self.types(instance = nil)
        ['load']
      end
    end
  end
end
