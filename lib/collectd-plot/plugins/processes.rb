

module CollectdPlot
  module Plugins
    module Processes

      def self.massage_graph_opts!(opts)
        case opts[:type]
        when 'ps_state'
          opts[:title] = 'processes'
          opts[:ylabel] = 'processes'
          opts[:series] = {}
          ['paging', 'blocked', 'zombies', 'stopped', 'running', 'sleeping'].each do |s|
            opts[:series][s] = {:rrd => "ps_state-#{s}", :value => 'value'}
          end
        when 'fork_rate'
          opts[:title] = 'fork rate'
          opts[:ylabel] = 'forks/s'
          opts[:series] = {'fork rate' => {:rrd => 'fork_rate', :value => 'value'}}
        when 'ps_code'
          opts[:title] = "text resident set (#{opts[:instance]})"
          opts[:ylabel] = 'bytes'
          opts[:series] = {'trs' => {:rrd => opts[:type], :value => 'value'}}
        when 'ps_count'
          opts[:title] = "number of processes/threads (#{opts[:instance]})"
          opts[:ylabel] = ''
          opts[:series] = {
            'processes' => {:rrd => opts[:type], :value => 'processes'},
            'threads  ' => {:rrd => opts[:type], :value => 'threads'}
          }
        when 'ps_cputime'
          opts[:title] = "cpu time (#{opts[:instance]})"
          opts[:ylabel] = 's'
          opts[:series] = {
            'user  ' => {:rrd => opts[:type], :value => 'user'},
            'system' => {:rrd => opts[:type], :value => 'syst'}
          }
        when 'ps_disk_octets'
          opts[:title] = "disk traffic (#{opts[:instance]})"
          opts[:ylabel] = 'bytes/s'
          opts[:series] = {
            'read ' => {:rrd => opts[:type], :value => 'read'},
            'write' => {:rrd => opts[:type], :value => 'write'}
          }
        when 'ps_disk_ops'
          opts[:title] = "disk operations (#{opts[:instance]})"
          opts[:ylabel] = 'ops/s'
          opts[:series] = {
            'read ' => {:rrd => opts[:type], :value => 'read'},
            'write' => {:rrd => opts[:type], :value => 'write'}
          }
        when 'ps_data'
          opts[:title] = "data resident set (#{opts[:instance]})"
          opts[:ylabel] = 'bytes'
          opts[:series] = {'drs' => {:rrd => opts[:type], :value => 'value'}}
        when 'ps_pagefaults'
          opts[:title] = "pagefaults (#{opts[:instance]})"
          opts[:ylabel] = 'pagefaults'
          opts[:series] = {
            'major' => {:rrd => opts[:type], :value => 'majflt'},
            'minor' => {:rrd => opts[:type], :value => 'minflt'}
          }
        when 'ps_rss'
          opts[:title] = "resident segment size (#{opts[:instance]})"
          opts[:ylabel] = 'bytes'
          opts[:series] = {'rss' => {:rrd => opts[:type], :value => 'value'}}
        when 'ps_stacksize'
          opts[:title] = "stack size (#{opts[:instance]})"
          opts[:ylabel] = 'bytes'
          opts[:series] = {'stack size' => {:rrd => opts[:type], :value => 'value'}}
        when 'ps_vm'
          opts[:title] = "virtual memory (#{opts[:instance]})"
          opts[:ylabel] = ''
          opts[:series] = {'memory' => {:rrd => opts[:type], :value => 'value'}}
        else raise "unknown type: #{opts[:type]}"
        end

        opts[:line_width] = 1
        opts[:graph_type] = :line
        opts[:rrd_format] = '%5.1lf%s'
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
