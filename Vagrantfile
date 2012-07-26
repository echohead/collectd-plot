#!/usr/bin/ruby

CHEF_ROOT = "#{File.dirname(__FILE__)}/chef"
BOX = 'oneiric64_base'
BOX_URL = 'http://echohead.org/~tim/vagrant/oneiric64_base.box'

nodes = {
  :server => {
    :ip_address => '192.168.50.15',
    :roles => ['Dev-Collectd-Plot'],
#    :roles => ['Prod-Collectd-Plot'],
    :forwards => { 80 => 8081, 8080 => 8082 }
  }
}


Vagrant::Config.run do |global_config|

  nodes.each_pair do |name, opts|
    global_config.vm.define name do |config|
      config.vm.box = BOX
      config.vm.box_url = BOX_URL
      config.vm.boot_mode = :headless
      config.vm.name = name.to_s
      config.vm.host_name = name.to_s
      config.vm.network :hostonly, opts[:ip_address]
      opts[:forwards].each_pair do |from, to|
        config.vm.forward_port from, to
      end

      config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = "#{CHEF_ROOT}/cookbooks"
        chef.roles_path = "#{CHEF_ROOT}/roles"
        chef.data_bags_path = "#{CHEF_ROOT}/data_bags"
        opts[:roles].each do |role|
          chef.add_role role
        end
      end
    end
  end
end
