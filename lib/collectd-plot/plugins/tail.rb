

module CollectdPlot
  module Plugins
    module Tail
      def self.massage_graph_opts!(opts)
        opts[:title] = "users"
        opts[:ylabel] = 'users'
        opts[:series] = {
          'users' => {:rrd => 'users', :value => 'value'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%.1lf'
      end

      def self.types(instance = nil)
        []
      end
    end
  end
end