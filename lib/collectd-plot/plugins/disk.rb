

module CollectdPlot
  module Plugins
    module Disk
      def self.massage_graph_opts!(opts)
        opts[:title] = "disk space (#{opts[:metric].gsub(/^disk-/, '')})"
        opts[:ylabel] = 'bytes'
        opts[:series] = {
          'read'  => {:rrd => 'disk_', :value => 'value'},
          'write' => {:rrd => 'disk_', :value => 'value'}
        }
        opts[:line_width] = 1
        opts[:graph_type] = :stacked
        opts[:rrd_format] = '%5.1lf%s'
      end
    end
  end
end
