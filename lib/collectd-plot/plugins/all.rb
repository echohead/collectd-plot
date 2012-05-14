require 'collectd-plot/plugins/memory'


module CollectdPlot
  module Plugins

    def self.plugin_for(metric)
      return Memory if metric == 'memory'
      nil
    end
  end
end
