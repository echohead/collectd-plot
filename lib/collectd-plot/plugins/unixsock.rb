

module CollectdPlot
  module Plugins
    module Unixsock

      def self.get_series(host, instance)
        RRDRead.rrd_files(host, "unixsock-#{instance}").map { |f| f.gsub(/.rrd$/, '') }
      end
 
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = opts[:instance]
          res[:ylabel] = ''
 
          res[:series] = {}
          get_series(opts[:host], opts[:instance]).each do |s|
            res[:series][s] = {:rrd => s, :value => 'value'}
          end

          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%.1lf'
        end
      end

      def self.types(instance = nil)
        ['unixsock']
      end
    end
  end
end
