# this recipe starts the service with passenger on apache

include_recipe 'collectd-plot::common'

packages = [
  'apache2',
  'build-essential',
  'libcurl4-openssl-dev',
  'zlib1g-dev',
  'apache2-prefork-dev',
  'libapr1-dev',
  'libaprutil1-dev'
]

packages.each do |p|
  package p do
    action :install
  end
end

template '/etc/collectd-plot.conf' do
  source 'collectd-plot.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
end

if not File.exists?('/etc/apache2/sites-available/collectd-plot')

  bash 'Install Passenger Apaache mod' do
    user 'root'
    code 'passenger-install-apache2-module --auto'
  end

  template '/etc/apache2/sites-available/collectd-plot' do
    source 'collectd-plot-apache.erb'
    mode 0644
    owner 'root'
    group 'root'
  end

  template '/etc/apache2/conf.d/passenger' do
    source 'passenger-apache.erb'
    mode 0644
    owner 'root'
    group 'root'
  end

  bash 'Enable collectd-plot with Passenger' do
    user 'root'
    code <<-EOS
      a2ensite collectd-plot
      a2dissite default
      service apache2 reload
    EOS
  end

end

