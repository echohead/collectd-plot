# this is a recipe for running collectd-plot inside a vagrant vm.
# it expects for the root of this repo to be mounted within the vm
# as /vagrant/.

packages = [
  'ruby1.9.1',
  'git',
  'rrdtool',
  'librrd-dev',
  'libxml2-dev',
  'libxslt1-dev'
]

packages.each do |p|
  package p do
    action :install
  end
end

script 'Ruby 1.9 as Default' do
  interpreter 'bash'
  user 'root'
  code <<-EOS
    update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1
  EOS
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
