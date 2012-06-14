require 'errand'
require 'RRD'
require 'collectd-plot/plugins/all'

# Read RRD info from the local filesystem.

module CollectdPlot
  module RRDRead
    # TODO: get this from config.
    RRDDIR = CollectdPlot::Config.rrd_dir || "#{File.dirname(__FILE__)}/../../spec/fixtures/rrd"
    raise "bad rrd directory: #{RRDDIR}" unless File.exists?(RRDDIR)

    def self.rrd_path(host, plugin, instance, rrd)
      dir = plugin + (instance.empty? ? '' : "-#{instance}")
      "#{RRDDIR}/#{host}/#{dir}/#{rrd}.rrd"
    end

    def self.rrd_files(host, plugin)
      Dir.glob("#{RRDDIR}/#{host}/#{plugin}/*").map { |f| File.basename f }
    end

    def self.list_hosts
      Dir.glob("#{RRDDIR}/*").map { |p| File.basename p }
    end

    def self.regexp_hosts(glob)
      Dir.glob("#{RRDDIR}/*").each { |d| puts d }
    end

    def self.list_metrics_for(h)
      {}.tap do |res|
        Dir.glob("#{RRDDIR}/#{h}/*").map {|m| File.basename m }.each do |dir|
          plugin, instance, rrds = CollectdPlot::Plugins.dir_info dir
          res[plugin] ||= {}
          res[plugin][instance] ||= []
          res[plugin][instance].concat rrds
        end
      end
    end

    def self.list_instances_for(h, m)
      Dir.glob("#{RRDDIR}/#{h}/#{m}/*").map { |m| File.basename m, ".*" }
    end

    def self.rrd_file(host, plugin, instance, rrd)
      File.read(rrd_path(host, plugin, instance, rrd))
    end

    def self.rrd_data(host, plugin, instance, rrd, start, stop)
      (fstart, fend, vals, data) = RRD.fetch(rrd_path(host, plugin, instance, rrd), '--start', start, '--end', stop, 'AVERAGE')
      step = (fend - fstart) / (data.length - 1)
      res = []
      data.each_with_index do |v, i|
        res << [fstart + step * i, v.first]
      end
      res[0...(res.length - 1)].map { |point| point.last.nan? ? [point.first, nil] : point }
    end

  end
end
