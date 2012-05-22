

module CollectdPlot
  module Plugins
    module Ntpd

      def self.get_series(host, type)
        RRDRead.rrd_files(host, 'ntpd').select { |f| f =~ Regexp.new('^' + type) }.map { |f| f.gsub(Regexp.new(type + '-'), '') }.map { |f| f.gsub(/.rrd$/, '') }
      end

      def self.massage_graph_opts!(opts)
        case opts[:type]
        when 'delay'
          opts[:title] = 'delay'
          opts[:ylabel] = 'seconds'
        when 'frequency_offset'
          opts[:title] = 'frequency offset'
          opts[:ylabel] = 'ppm'
        when 'time_dispersion'
          opts[:title] = 'time dispersion'
          opts[:ylabel] = 'seconds'
        when 'time_offset'
          opts[:title] = 'time offset'
          opts[:ylabel] = 'seconds'
        else raise "unknown type: #{opts[:type]}"
        end

        opts[:series] = {}
        get_series(opts[:host], opts[:type]).each do |s|
          opts[:series][s] = {:rrd => "#{opts[:type]}-#{s}", :value => 'value'}
        end

        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types()
        ['delay', 'frequency_offset', 'time_dispersion', 'time_offset']
      end
    end
  end
end
