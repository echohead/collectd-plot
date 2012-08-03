

module CollectdPlot
  module Plugins
    module Cpu
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = "#{opts[:metric]} usage"
          res[:ylabel] = 'jiffies'
          res[:series] = {
            'idle     ' => {:rrd => 'cpu-idle', :value => 'value', :color => 'DDDDDD'},
            'nice     ' => {:rrd => 'cpu-nice', :value => 'value'},
            'user     ' => {:rrd => 'cpu-user', :value => 'value'},
            'wait     ' => {:rrd => 'cpu-wait', :value => 'value'},
            'system   ' => {:rrd => 'cpu-system', :value => 'value'},
            'softirq  ' => {:rrd => 'cpu-softirq', :value => 'value'},
            'interrupt' => {:rrd => 'cpu-interrupt', :value => 'value'},
            'steal    ' => {:rrd => 'cpu-steal', :value => 'value'},
          }
          res[:line_width] = 1
          res[:graph_type] = :stacked
          res[:rrd_format] = '%5.2lf'
        end
      end

      def self.types(instance = nil)
        ['cpu']
      end
    end
  end
end
