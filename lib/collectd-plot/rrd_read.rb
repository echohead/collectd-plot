require 'errand'

module CollectdPlot
  module RRDRead
    # TODO: get this from config.
    RRDDIR = '/vagrant/spec/fixtures/rrd/'

    def self.list_hosts
      Dir.glob("#{RRDDIR}/*").map { |p| File.basename p }
    end

    def self.regexp_hosts(glob)
      Dir.glob("#{RRDDIR}/*").each { |d| puts d }
    end

    def self.list_metrics_for(h)
      Dir.glob("#{RRDDIR}/#{h}/*").map { |m| File.basename m }
    end

    def self.rrd_file(host, metric, instance)
      File.read("#{RRDDIR}/#{host}/#{metric}/#{instance}.rrd")
    end

  end
end
