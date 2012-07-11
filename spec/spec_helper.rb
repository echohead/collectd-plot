# Load the Sinatra app
#require "#{File.dirname(__FILE__)}/../lib/collectd-plot"
require 'rspec'
require 'rack/test'
require 'collectd-plot'

require 'rack/protection'
use Rack::Protection, :except => :json_csrf

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  CollectdPlot::Service
end

def get_json(path, params = {})
  get(path, params, {'HTTP_ACCEPT' => 'application/json'})
end

def get_csv(path, params = {})
  get(path, params, {'HTTP_ACCEPT' => 'text/csv'})
end

def api_fixture_data(filename)
  File.read("#{File.dirname __FILE__}/fixtures/api_data/#{filename}")
end
