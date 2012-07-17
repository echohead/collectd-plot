#
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "collectd-plot"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Tim Miller" ]
  s.email       = [ "" ]
  s.homepage    = "https://github.com/echohead/collectd-plot"
  s.summary     = %q{A web interface for Collectd}
  s.description = %q{Plot collectd data using gnuplot, with useful features such as host globbing.}

  s.required_ruby_version     = ">= 1.9.1"
  s.required_rubygems_version = ">= 1.3.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency     "haml",            "= 3.1.4"
  s.add_runtime_dependency     "tilt",            "= 1.3.3"
  s.add_runtime_dependency     "sinatra",         "= 1.3.2"
  s.add_runtime_dependency     "errand",          "= 0.7.3"
  s.add_runtime_dependency     "httparty",        ">= 0"
  s.add_runtime_dependency     "librrd",          "= 1.0.2"
  s.add_runtime_dependency     "redis",           ">= 2.2.2"
  s.add_runtime_dependency     "unicorn",         ">= 0"
  s.add_development_dependency "shotgun",         ">= 0"
  s.add_development_dependency "rack-test",       ">= 0"
  s.add_development_dependency "rake",            ">= 0"
  s.add_development_dependency "rspec",           ">= 0"
  s.add_development_dependency "webrat",          ">= 0"
  s.add_development_dependency "colorize",        ">= 0"
end
