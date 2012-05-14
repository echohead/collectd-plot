

module CollectdPlot
  module Plugins
    module Memory
      def self.massage_graph_opts!(opts)
        opts[:ylabel] = 'Bytes'
      end
    end
  end
end
