

module CollectdPlot
  module Plugins
    module UnixSock

      def self.get_series(host, instance)
        RRDRead.rrd_files(host, "unixsock-#{instance}").map { |f| f.gsub(/.rrd$/, '') }
      end
 
      def self.massage_graph_opts!(opts)
        opts[:title] = opts[:instance]
        opts[:ylabel] = ''

        opts[:series] = {}
        get_series(opts[:host], opts[:instance]).each do |s|
          opts[:series][s] = {:rrd => s, :value => 'value'}
        end

        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%.1lf'
      end

      def self.types(instance = nil)
        ['unixsock']
      end
    end
  end
end
