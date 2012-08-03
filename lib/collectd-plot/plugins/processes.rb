

module CollectdPlot
  module Plugins
    module Processes

      def self.massage_graph_opts(opts)
        {}.tap do |res|
          case opts[:type]
          when 'ps_state'
            res[:title] = 'processes'
            res[:ylabel] = 'processes'
            res[:series] = {}
            ['paging', 'blocked', 'zombies', 'stopped', 'running', 'sleeping'].each do |s|
              res[:series][s] = {:rrd => "ps_state-#{s}", :value => 'value'}
            end
          when 'fork_rate'
            res[:title] = 'fork rate'
            res[:ylabel] = 'forks/s'
            res[:series] = {'fork rate' => {:rrd => 'fork_rate', :value => 'value'}}
          when 'ps_code'
            res[:title] = "text resident set (#{opts[:instance]})"
            res[:ylabel] = 'bytes'
            res[:series] = {'trs' => {:rrd => opts[:type], :value => 'value'}}
          when 'ps_count'
            res[:title] = "number of processes/threads (#{opts[:instance]})"
            res[:ylabel] = ''
            res[:series] = {
              'processes' => {:rrd => opts[:type], :value => 'processes'},
              'threads  ' => {:rrd => opts[:type], :value => 'threads'}
            }
          when 'ps_cputime'
            res[:title] = "cpu time (#{opts[:instance]})"
            res[:ylabel] = 's'
            res[:series] = {
              'user  ' => {:rrd => opts[:type], :value => 'user'},
              'system' => {:rrd => opts[:type], :value => 'syst'}
            }
          when 'ps_disk_octets'
            res[:title] = "disk traffic (#{opts[:instance]})"
            res[:ylabel] = 'bytes/s'
            res[:series] = {
              'read ' => {:rrd => opts[:type], :value => 'read'},
              'write' => {:rrd => opts[:type], :value => 'write'}
            }
          when 'ps_disk_ops'
            res[:title] = "disk operations (#{opts[:instance]})"
            res[:ylabel] = 'ops/s'
            res[:series] = {
              'read ' => {:rrd => opts[:type], :value => 'read'},
              'write' => {:rrd => opts[:type], :value => 'write'}
            }
          when 'ps_data'
            res[:title] = "data resident set (#{opts[:instance]})"
            res[:ylabel] = 'bytes'
            res[:series] = {'drs' => {:rrd => opts[:type], :value => 'value'}}
          when 'ps_pagefaults'
            res[:title] = "pagefaults (#{opts[:instance]})"
            res[:ylabel] = 'pagefaults'
            res[:series] = {
              'major' => {:rrd => opts[:type], :value => 'majflt'},
              'minor' => {:rrd => opts[:type], :value => 'minflt'}
            }
          when 'ps_rss'
            res[:title] = "resident segment size (#{opts[:instance]})"
            res[:ylabel] = 'bytes'
            res[:series] = {'rss' => {:rrd => opts[:type], :value => 'value'}}
          when 'ps_stacksize'
            res[:title] = "stack size (#{opts[:instance]})"
            res[:ylabel] = 'bytes'
            res[:series] = {'stack size' => {:rrd => opts[:type], :value => 'value'}}
          when 'ps_vm'
            res[:title] = "virtual memory (#{opts[:instance]})"
            res[:ylabel] = ''
            res[:series] = {'memory' => {:rrd => opts[:type], :value => 'value'}}
          else raise "unknown type: #{opts[:type]}"
          end

          res[:line_width] = 1
          res[:graph_type] = :line
          res[:rrd_format] = '%5.1lf%s'
        end
      end

      def self.types(instance)
        if instance and !instance.empty?
          ['ps_code', 'ps_count', 'ps_cputime', 'ps_disk_octets', 'ps_disk_ops',
           'ps_data', 'ps_pagefaults', 'ps_rss', 'ps_stacksize', 'ps_vm']
        else
          ['ps_state', 'fork_rate']
        end
      end
    end
  end
end
