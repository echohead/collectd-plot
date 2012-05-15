require 'collectd-plot/plugins/cpu'
require 'collectd-plot/plugins/default'
require 'collectd-plot/plugins/load'
require 'collectd-plot/plugins/memory'

module CollectdPlot
  module Plugins

    PLUGINS = {
      /^cpu/ => Cpu,
      /^load/ => Load,
      /^memory/ => Memory,
      /.*/ => Default
    }

    def self.plugin_for(metric)
      PLUGINS.each_pair do |match, plugin|
        return plugin if metric =~ match
      end
    end
  end
end
