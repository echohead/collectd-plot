require 'errand'
require 'RRD'
require 'collectd-plot/cache'
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
      opts[:graph_type] = 'default' if opts[:graph_type] != 'line' && opts[:graph_type] != 'stacked'
      opts[:colors] = opts[:colors].split(',') if opts[:colors]
      graph_type = opts[:graph_type].to_sym

      selected_graph_type = opts[:graph_type]
      opts[:x] ||= 400
      opts[:y] ||= 300
      opts[:x] = 800 if opts[:x].to_i > 800
      opts[:y] = 800 if opts[:y].to_i > 800
      opts[:x] = 100 if opts[:x].to_i < 100
      opts[:y] = 100 if opts[:y].to_i < 100
      opts[:start] ||= 'end-24h'
      opts[:end] ||= 'now'

      plugin = CollectdPlot::Plugins.plugin_by_name(opts[:plugin])
      plugin.massage_graph_opts!(opts) if plugin

      opts[:graph_type] = graph_type if graph_type != :default # override graph type if the user chooses to.
      opts[:title] ||= "#{opts[:host]} #{opts[:instance]}"
      opts[:line_width] ||= 2
      opts[:graph_type] ||= :line
      opts[:rrd_format] ||= '%.2lf'
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
      hsv_to_rgb(i.to_f / of_n.to_f, 0.95, 0.95)
    end

    def self.each_pair_with_index(hash)
      i = 0
      hash.each_pair do |k, v|
        yield k, v, i
        i += 1
      end
    end


    def self.stacked_args(opts)
      res = []
      series = opts[:series]
      each_pair_with_index(opts[:series]) do |name, props, i|
        rrd = RRDRead.rrd_path opts[:host], opts[:plugin], opts[:instance], props[:rrd]

        # display legend with min, max, avg
        res.concat [ "DEF:min#{i}=#{rrd}:#{props[:value]}:MIN" ]
        res.concat [ "DEF:avg#{i}=#{rrd}:#{props[:value]}:AVERAGE" ]
        res.concat [ "DEF:max#{i}=#{rrd}:#{props[:value]}:MAX" ]
      end
      (series.length - 1).downto(0) do |i|
        if i == series.length - 1
          res << "CDEF:area#{i}=avg#{i}"
        else
          res << "CDEF:area#{i}=avg#{i},area#{i+1},+"
        end
      end
      series.keys.each_with_index do |name, i|
        color = (opts[:colors] and opts[:colors].length > i) ? opts[:colors][i] : rand_color(i, series.size)
        res << "AREA:area#{i}##{series[name][:color] ? series[name][:color] : color}:#{name}"
        res.concat [ "GPRINT:min#{i}:MIN:#{opts[:rrd_format]} min" ]
        res.concat [ "GPRINT:avg#{i}:AVERAGE:#{opts[:rrd_format]} avg" ]
        res.concat [ "GPRINT:max#{i}:MAX:#{opts[:rrd_format]} max\\l" ]
      end
      res.concat [ "HRULE:#{opts[:threshold]}#000000:threshold:dashes=on" ] if opts[:threshold]
      res
    end

    def self.line_args(opts)
      res = []
      each_pair_with_index(opts[:series]) do |name, props, i|
        rrd = RRDRead.rrd_path opts[:host], opts[:plugin], opts[:instance], props[:rrd]

        # print a line for this metric
        res.concat [ "DEF:value#{i}=#{rrd}:#{props[:value]}:AVERAGE" ]
        color = (opts[:colors] and opts[:colors].length > i) ? opts[:colors][i] : rand_color(i, opts[:series].size)
        res.concat [ "LINE#{opts[:line_width]}:value#{i}##{props[:color] ? props[:color] : color}:#{name}" ]

        # display legend with min, max, avg
        res.concat [ "DEF:min#{i}=#{rrd}:#{props[:value]}:MIN" ]
        res.concat [ "DEF:avg#{i}=#{rrd}:#{props[:value]}:AVERAGE" ]
        res.concat [ "DEF:max#{i}=#{rrd}:#{props[:value]}:MAX" ]
        res.concat [ "GPRINT:min#{i}:MIN:#{opts[:rrd_format]} min" ]
        res.concat [ "GPRINT:avg#{i}:AVERAGE:#{opts[:rrd_format]} avg" ]
        res.concat [ "GPRINT:max#{i}:MAX:#{opts[:rrd_format]} max\\l" ]
      end
      res.concat [ "HRULE:#{opts[:threshold]}#000000:threshold:dashes=on" ] if opts[:threshold]
      res
    end
 
    def self.graph(opts)
      massage_graph_opts!(opts)
      CollectdPlot::Cache.instance.get("graph.#{opts.to_json}") do


        temp_file_contents do |tmp|
          args = [
            tmp,
            "--title", "#{opts[:title]} on #{opts[:host]}",
            '--start', opts[:start],
            '--end', opts[:end],
            "--interlace", "--imgformat", "PNG",
            "--width=#{opts[:x]}",
            "--height=#{opts[:y]}",
          ]

          if opts[:graph_type] == :stacked
            args.concat stacked_args(opts)
          else
            args.concat line_args(opts)
          end

          args.concat [ '--vertical-label', opts[:ylabel] ] if opts[:ylabel]

          RRD.graph(*args)
         end
       end
    end
  end
end
