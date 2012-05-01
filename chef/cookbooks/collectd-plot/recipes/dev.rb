# this is a recipe for running collectd-plot inside a vagrant vm.


script 'Start the service with shotgun' do
  interpreter 'bash'
  cwd node[:collectd_plot][:root]
  code 'sudo nohup shotgun --port 80 --host 10.0.2.15 lib/collectd-plot/config.ru >/dev/null 2>&1 &'
end
