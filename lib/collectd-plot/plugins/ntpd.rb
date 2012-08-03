

module CollectdPlot
  module Plugins
    module Ntpd

      def self.get_series(host, type)
        RRDRead.rrd_files(host, 'ntpd').select { |f| f =~ Regexp.new('^' + type) }.map { |f| f.gsub(Regexp.new(type + '-'), '') }.map { |f| f.gsub(/.rrd$/, '') }
      end

      def self.massage_graph_opts(opts)
        {}.tap do |res|
          case opts[:type]
          when 'delay'
            res[:title] = 'delay'
            res[:ylabel] = 'seconds'
          when 'frequency_offset'
            res[:title] = 'frequency offset'
            res[:ylabel] = 'ppm'
          when 'time_dispersion'
            res[:title] = 'time dispersion'
            res[:ylabel] = 'seconds'
          when 'time_offset'
            res[:title] = 'time offset'
            res[:ylabel] = 'seconds'
          else raise "unknown type: #{opts[:type]}"
          end

          res[:series] = {}
          get_series(opts[:host], opts[:type]).each do |s|
            res[:series][s] = {:rrd => "#{opts[:type]}-#{s}", :value => 'value'}
          end

          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['delay', 'frequency_offset', 'time_dispersion', 'time_offset']
      end
    end
  end
end
