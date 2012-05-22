require 'collectd-plot/plugins/cpu'
require 'collectd-plot/plugins/default'
require 'collectd-plot/plugins/df'
require 'collectd-plot/plugins/disk'
require 'collectd-plot/plugins/interface'
require 'collectd-plot/plugins/load'
require 'collectd-plot/plugins/memory'
require 'collectd-plot/plugins/ntpd'
require 'collectd-plot/plugins/processes'
require 'collectd-plot/plugins/tail'
require 'collectd-plot/plugins/uptime'
require 'collectd-plot/plugins/users'
require 'collectd-plot/plugins/vmem'

module CollectdPlot
  module Plugins

    PLUGINS = {
      Cpu => /^cpu-/,
      Df => /^df-/,
      Disk => /^disk-/,
      Interface => /^interface-/,
      Load => /^load$/,
      Memory => /^memory$/,
      Ntpd => /^ntpd$/,
      Processes => /^processes-?/,
      Tail => /^tail-/,
      Uptime => /^uptime$/,
      Users => /^users$/,
      Vmem => /^vmem$/,
      Default => /.*/,
    }

    def self.plugin_by_name(name)
      const_get(name.capitalize)
    end

    def self.plugin_for(dir_name)
      PLUGINS.each_pair do |plugin, match|
        return plugin if dir_name =~ match
      end
    end

    def self.plugin_name(dir_name)
      plugin_for(dir_name).to_s.gsub(/.*::/, '').downcase
    end

    def self.instance_for(dir_name)
      dir_name.gsub(PLUGINS[plugin_for(dir_name)], '')
    end

    def self.types_for(dir_name)
      plugin_for(dir_name).types(instance_for(dir_name))
    end

    def self.dir_info(dir_name)
      [ plugin_name(dir_name), instance_for(dir_name), types_for(dir_name) ]
    end
  end
end
