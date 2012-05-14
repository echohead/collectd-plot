require 'collectd-plot/plugins/memory'
require 'collectd-plot/plugins/load'

module CollectdPlot
  module Plugins

    PLUGINS = {
      /^memory/ => Memory,
      /^load/ => Load
    }

    def self.plugin_for(metric)
      PLUGINS.each_pair do |match, plugin|
        return plugin if metric =~ match
      end
    end
  end
end
