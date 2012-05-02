require 'spec_helper'

describe 'the service' do

  it 'should list hosts' do
get '/hosts.json'
puts 'XXXX' + last_response.body
    JSON.parse(get('/hosts.json').body).should == ['host_a', 'host_b']
  end

  it 'should list metrics for a host' do
    JSON.parse(get('/hosts/host_a.json').body).should == ['df-root', 'load', 'memory']
  end

  it 'should give an empty array for unknown hosts' do
    JSON.parse(get('/hosts/foobar.json').body).should == []
  end

  it 'returns the rrd file for a given metric' do
    actual = get('/hosts/host_a/metric/memory/instance/memory-free/rrd').body
    expected = File.read("#{File.dirname(__FILE__)}/fixtures/rrd/host_a/memory/memory-free.rrd")
    actual.should == expected
  end

  it 'returns rrd data for a metric' do
    start = 1335739560
    stop = start + 1000
    'todo'
  end

  it 'sandbox' do
#    get '/sandbox'
  end

end
