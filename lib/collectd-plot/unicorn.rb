worker_processes CollectdPlot::Config.num_workers

working_directory CollectdPlot::Config.root

listen "/tmp/.sock", :backlog => 64
listen 5000, :tcp_nopush => true

timeout 30

# feel free to point this anywhere accessible on the filesystem
pid '/var/run/collectd-plot/unicorn.pid'

stderr_path '/var/log/collectd-plot/err.log'
stdout_path '/var/log/collectd-plot/out.log'

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
end

after_fork do |server, worker|
end
