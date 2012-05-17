require 'errand'
require 'RRD'

# Read RRD info from the local filesystem.

module CollectdPlot
  module RRDRead
    # TODO: get this from config.
puts CollectdPlot::Config.inspect
    RRDDIR = CollectdPlot::Config.rrd_dir
    raise "bad rrd directory: #{RRDDIR}" unless File.exists?(RRDDIR)

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

  end
end
