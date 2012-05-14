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

      opts[:title] ||= "#{opts[:host]} #{opts[:instance]}"
      opts[:line_width] ||= 2
    end


    def self.hsv_to_rgb(h, s, v)
      h_i = (h*6).to_i
      f = h*6 - h_i
      p = v * (1 - s)
      q = v * (1 - f*s)
      t = v * (1 - (1 - f) * s)
      r, g, b = v, t, p if h_i==0
      r, g, b = q, v, p if h_i==1
      r, g, b = p, v, t if h_i==2
      r, g, b = p, q, v if h_i==3
      r, g, b = t, p, v if h_i==4
      r, g, b = v, p, q if h_i==5
      [(r*256).to_i, (g*256).to_i, (b*256).to_i].map { |e| e.to_s(16) }.map { |hex| hex.length == 2 ? hex : "0#{hex}" }.join('')
    end


    def self.rand_color(i, of_n)
      random = Random.new(i.to_f * of_n.to_f)
      hsv_to_rgb(i.to_f / of_n.to_f, 0.5, 0.95)
      #hsv_to_rgb(random.rand, 0.5, 0.95)
    end

    def self.each_pair_with_index(hash)
      i = 0
      hash.each_pair do |k, v|
        yield k, v, i
        i += 1
      end
    end
 
    def self.graph(opts)
      massage_graph_opts!(opts)
      rrd = RRDRead.rrd_path(opts[:host], opts[:metric], opts[:instance])


      temp_file_contents do |tmp|
        args = [
          tmp,
          "--title", "#{opts[:title]} on #{opts[:host]}",
          '--start', opts[:start],
          '--end', opts[:end],
          "--interlace", "--imgformat", "PNG",
          "--width=#{opts[:x]}",
          "--height=#{opts[:y]}",
#          "DEF:value=#{rrd}:#{opts[:value]}:AVERAGE", "LINE2:value#ff0000"
        ]

        num_lines = opts[:series].length
        each_pair_with_index(opts[:series]) do |name, props, i|
          rrd = RRDRead.rrd_path opts[:host], opts[:metric], props[:rrd]
          args.concat [ "DEF:value#{i}=#{rrd}:#{props[:value]}:AVERAGE", "LINE#{opts[:line_width]}:value#{i}##{rand_color i, num_lines}:#{name}" ]
        end
        args.concat [ '--vertical-label', opts[:ylabel] ] if opts[:ylabel]

        RRD.graph(*args)
       end
     end
  end
end
