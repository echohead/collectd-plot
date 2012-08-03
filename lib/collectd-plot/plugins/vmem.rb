

module CollectdPlot
  module Plugins
    module Vmem

      def self.get_series(host, type)
        RRDRead.rrd_files(host, 'vmem').select { |f| f =~ Regexp.new('^' + type) }.map { |f| f.gsub(Regexp.new(type + '-'), '') }.map { |f| f.gsub(/.rrd$/, '') }
      end

      def self.massage_graph_opts(opts)
        {}.tap do |res|
          case opts[:type]
          when 'vmpage_faults'
            res[:title] = 'page faults'
            res[:ylabel] = ''
            res[:series] = {
              'minor' => {:rrd => opts[:type], :value => 'minflt', :color => '0000CC'},
              'major' => {:rrd => opts[:type], :value => 'majflt', :color => 'FF0000'}
            }
            res[:graph_time] = :line
          when 'vmpage_io'
            res[:title] = 'page i/o'
            res[:ylabel] = ''
            res[:series] = {
              'memory (in) ' => {:rrd => 'vmpage_io-memory', :value => 'in'},
              'memory (out)' => {:rrd => 'vmpage_io-memory', :value => 'out'},
              'swap   (in) ' => {:rrd => 'vmpage_io-swap', :value => 'in'},
              'swap   (out)' => {:rrd => 'vmpage_io-swap', :value => 'out'}
            }
            res[:graph_type] = :line
          when 'vmpage_number'
            res[:title] = 'pages'
            res[:ylabel] = ''
            res[:series] = {}
            ['active_anon', 'active_file', 'anon_pages', 'bounce', 'dirty', 'file_pages', 'free_pages', 'inactive_anon',
             'inactive_file', 'mapped', 'mlock', 'page_table_pages', 'slab_reclaimable', 'slab_unreclaimable', 'unevictable',
             'unstable', 'writeback', 'writeback_temp'].each do |s|
              res[:series][s + (' '*(18-s.length))] = {:rrd => "vmpage_number-#{s}", :value => 'value'}
            end
            res[:graph_type] = :stacked
          else raise "unknown type: #{opts[:type]}"
          end

          res[:line_width] = 1
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance = nil)
        ['vmpage_faults', 'vmpage_io', 'vmpage_number']
      end
    end
  end
end
