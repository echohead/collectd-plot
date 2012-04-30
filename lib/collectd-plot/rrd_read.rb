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

    def self.get_data(props)
      data = {}
      rrd_name = "#{RRDDIR}#{props.host}/load/load.rrd"      
      rrd = Errand.new(:filename => rrd_name)

puts rrd.fetch(:function => 'AVERAGE', :start => props.start, :finish => props.finish).inspect
      rrd_data = rrd.fetch(:function => 'AVERAGE', :start => props.start, :finish => props.finish)[:data]
      res = {}
      rrd_data.each_pair do |source, metric|
        metric.map! do |datapoint|
          case
          when datapoint && datapoint.nan?
            @tripped = true
            @last_valid
          when @tripped
            @last_valid
          else
            @last_valid = datapoint
          end
        end
        data[props.host] = metric
     end
     data
   end
=begin
        props.host_a
          props[
          # Last value is always wack. Set to 0, so the timescale isn't off by 1.
          metric[-1] = 0.0

          res[d[:host]] ||= {}
          res[d[:host]][d[:plugin]] ||= {}
          res[d[:host]][d[:plugin]][d[:instance]] ||= {}
          res[d[:host]][d[:plugin]][d[:instance]][source] ||= {}
          res[d[:host]][d[:plugin]][d[:instance]][source][:start]  ||= d[:start].to_i
          res[d[:host]][d[:plugin]][d[:instance]][source][:finish] ||= d[:finish].to_i
          res[d[:host]][d[:plugin]][d[:instance]][source][:data]   ||= metric
        end
        res
=end
  end
end
