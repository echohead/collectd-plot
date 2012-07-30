require 'rubygems'
require 'rspec/core/rake_task'
require 'RRD'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--color'
end
