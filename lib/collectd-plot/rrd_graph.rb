require 'errand'
require 'RRD'
require 'collectd-plot/plugins/all'

module CollectdPlot
  module RRDGraph

    def self.temp_file_contents
      f = Tempfile.new('collectd-plot')
      yield f.path
      res = File.read f.path
      File.delete f.path
      res
    end


    def self.massage_graph_opts!(opts)
      opts[:x] = 800 if opts[:x].to_i > 800
      opts[:y] = 800 if opts[:y].to_i > 800
      opts[:x] = 100 if opts[:x].to_i < 100
      opts[:y] = 100 if opts[:y].to_i < 100
      opts[:start] ||= 'end-24h'
      opts[:end] ||= 'now'

      plugin = CollectdPlot::Plugins.plugin_for(opts[:metric])
      plugin.massage_graph_opts!(opts) if plugin
    end

    
    def self.graph(opts)
      massage_graph_opts!(opts)
      rrd = RRDRead.rrd_path(opts[:host], opts[:metric], opts[:instance])


      temp_file_contents do |tmp|
        args = [
          tmp,
          "--title", "#{opts[:host]} #{opts[:instance]}",
          '--start', opts[:start],
          '--end', opts[:end],
          "--interlace", "--imgformat", "PNG",
          "--width=#{opts[:x]}",
          "--height=#{opts[:y]}",
          "DEF:value=#{rrd}:#{opts[:value]}:AVERAGE", "LINE2:value#ff0000"
        ]
        args.concat [ '--vertical-label', opts[:ylabel] ] if opts[:ylabel]

        RRD.graph(*args)
       end
     end
  end
end
