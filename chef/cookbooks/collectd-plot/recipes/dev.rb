# this is a recipe for running collectd-plot inside a vagrant vm.
# it expects for the root of this repo to be mounted within the vm
# as /vagrant/.

packages = [
  'ruby-1.9.1'
]

packages.each do |p|
  package p do
    action :install
  end
end

# install gems
script 'Install Bundled Gems' do
  interpreter 'bash'
  cwd '/vagrant'
  user 'root'
  code <<-EOS
    bundle isntall --quiet --development'
  EOS
end
