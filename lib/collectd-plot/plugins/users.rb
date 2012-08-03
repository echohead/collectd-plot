

module CollectdPlot
  module Plugins
    module Users
      def self.massage_graph_opts(opts)
        {}.tap do |res|
          res[:title] = "users"
          res[:ylabel] = 'users'
          res[:series] = {
            'users' => {:rrd => 'users', :value => 'value'}
          }
          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%.1lf'
        end
      end

      def self.types(instance = nil)
        ['users']
      end
    end
  end
end
