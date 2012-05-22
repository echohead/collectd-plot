

module CollectdPlot
  module Plugins
    module Vmem

      def self.get_series(host, type)
        RRDRead.rrd_files(host, 'vmem').select { |f| f =~ Regexp.new('^' + type) }.map { |f| f.gsub(Regexp.new(type + '-'), '') }.map { |f| f.gsub(/.rrd$/, '') }
      end

      def self.massage_graph_opts!(opts)
        case opts[:type]
        when 'vmpage_faults'
          opts[:title] = 'page faults'
          opts[:ylabel] = ''
          opts[:series] = {
            'minor' => {:rrd => opts[:type], :value => 'minflt', :color => '0000CC'},
            'major' => {:rrd => opts[:type], :value => 'majflt', :color => 'FF0000'}
          }
          opts[:graph_time] = :line
        when 'vmpage_io'
          opts[:title] = 'page i/o'
          opts[:ylabel] = ''
          opts[:series] = {
            'memory (in) ' => {:rrd => 'vmpage_io-memory', :value => 'in'},
            'memory (out)' => {:rrd => 'vmpage_io-memory', :value => 'out'},
            'swap   (in) ' => {:rrd => 'vmpage_io-swap', :value => 'in'},
            'swap   (out)' => {:rrd => 'vmpage_io-swap', :value => 'out'}
          }
          opts[:graph_type] = :line
        when 'vmpage_number'
          opts[:title] = 'pages'
          opts[:ylabel] = ''
          opts[:series] = {}
          ['active_anon', 'active_file', 'anon_pages', 'bounce', 'dirty', 'file_pages', 'free_pages', 'inactive_anon',
           'inactive_file', 'mapped', 'mlock', 'page_table_pages', 'slab_reclaimable', 'slab_unreclaimable', 'unevictable',
           'unstable', 'writeback', 'writeback_temp'].each do |s|
            opts[:series][s + (' '*(18-s.length))] = {:rrd => "vmpage_number-#{s}", :value => 'value'}
          end
          opts[:graph_type] = :stacked
        else raise "unknown type: #{opts[:type]}"
        end

        opts[:line_width] = 1
        opts[:rrd_format] = '%5.1lf%s'
      end

      def self.types(instance = nil)
        ['vmpage_faults', 'vmpage_io', 'vmpage_number']
      end
    end
  end
end
