#!/usr/bin/ruby

require 'pathname'
@root = File.dirname __FILE__
$: << @root.to_s

$0 = "collectd-plot"

require 'lib/collectd-plot/config'
if File.exists? '/etc/collectd-plot.conf' # TODO
  CollectdPlot::Config.from_file '/etc/collectd-plot.conf'
else
  CollectdPlot::Config.from_file "#{File.dirname __FILE__}/spec/fixtures/config.json"
end

require 'lib/collectd-plot'

run CollectdPlot::Service
