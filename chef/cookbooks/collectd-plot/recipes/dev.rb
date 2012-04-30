# this is a recipe for running collectd-plot inside a vagrant vm.
# it expects for the root of this repo to be mounted within the vm
# as /vagrant/.

packages = [
  'ruby1.9.1'
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
    gem1.9.1 install bundler && bundle install --quiet --development
  EOS
end
