require 'errand'
require 'RRD'

# Read RRD info from the local filesystem.

module CollectdPlot
  module RRDRead
    # TODO: get this from config.
    RRDDIR = "#{File.dirname(__FILE__)}/../../spec/fixtures/rrd"

    def self.rrd_path(host, metric, instance)
      "#{RRDDIR}/#{host}/#{metric}/#{instance}.rrd"
    end

    def self.list_hosts
      Dir.glob("#{RRDDIR}/*").map { |p| File.basename p }
    end

    def self.regexp_hosts(glob)
      Dir.glob("#{RRDDIR}/*").each { |d| puts d }
    end

    def self.list_metrics_for(h)
      {}.tap do |res|
        Dir.glob("#{RRDDIR}/#{h}/*").map {|m| File.basename m }.each do |m|
          res[m] = Dir.glob("#{RRDDIR}/#{h}/#{m}/*").map { |i| File.basename(i).gsub(/.rrd$/, '') }.sort
        end
      end
    end

    def self.list_instances_for(h, m)
      Dir.glob("#{RRDDIR}/#{h}/#{m}/*").map { |m| File.basename m, ".*"}
    end

    def self.rrd_file(host, metric, instance)
      File.read(rrd_path(host, metric, instance))
    end

    def self.rrd_data(host, metric, instance, start, stop)
      (fstart, fend, vals, data) = RRD.fetch(rrd_path(host, metric, instance), '--start', start, '--end', stop, 'AVERAGE')
      data
    end


    def self.temp_file_contents
      f = Tempfile.new('collectd-plot')
      yield f.path
      res = File.read f.path
      File.delete f.path
      res
    end


    def self.sanitize_graph_opts!(opts)
      opts[:x] = 800 if opts[:x].to_i > 800
      opts[:y] = 800 if opts[:y].to_i > 800
      opts[:x] = 100 if opts[:x].to_i < 100
      opts[:y] = 100 if opts[:y].to_i < 100
      opts[:start] ||= 'end-24h'
      opts[:end] ||= 'now'
    end

    
    def self.graph(opts)
      sanitize_graph_opts!(opts)
      rrd = rrd_path(opts[:host], opts[:metric], opts[:instance])


      temp_file_contents do |tmp|
        RRD.graph(tmp,
          "--title", "#{opts[:host]} #{opts[:instance]}", '--start', opts[:start], '--end', opts[:end],
          "--interlace", "--imgformat", "PNG",
          "--width=#{opts[:x]}", "--height=#{opts[:y]}", "DEF:value=#{rrd}:#{opts[:value]}:AVERAGE",
          "LINE2:value#ff0000")
       end
     end
  end
end
