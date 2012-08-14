require 'spec_helper'

describe 'the service' do
  before :all do
    CollectdPlot::Cache.instance.delete_keys
  end

  before :each do
    CollectdPlot::Config.clear!
    CollectdPlot::Config.from_file("#{File.dirname(__FILE__)}/fixtures/config.json")
  end

  context 'when running on a persistence shard' do

    before :each do
      CollectdPlot::Config.proxy = false
    end

    it 'should list hosts' do
      JSON.parse(get_json('/hosts').body).should == ['host_125', 'host_23', 'host_a', 'host_b']
    end

    it 'should list metrics for a host' do
      JSON.parse(get_json('/host/host_a').body).should == JSON.parse(api_fixture_data 'host_a_rrds.json')
    end

    it 'should list instances for a metric' do
      JSON.parse(get_json('/host/host_a/plugin/load').body).should == ['load']
    end

    it 'should give an empty hash for unknown hosts' do
      JSON.parse(get_json('/host/foobar').body).should == {}
    end

    it 'should return the rrd file for a given metric' do
      actual = get('/rrd/host_a/cpu/0/cpu-user').body
      expected = File.read("#{File.dirname(__FILE__)}/fixtures/rrd/host_a/cpu-0/cpu-user.rrd")
      actual.should == expected
    end

    it 'returns rrd data for a metric as csv' do
      params = {
        :start => 1335739560,
        :end => 1335740560,
        :host => 'host_a',
        :plugin => 'memory',
        :instance => '',
        :rrd => 'memory-free',
        :value => 'value'
      }
      RRD.stub(:fetch).and_return(JSON.parse(api_fixture_data('host_a_memory.raw')))
      get_csv('/rrd_data', params).body.should == api_fixture_data('host_a_memory.csv')
    end

    it 'returns rrd data for a metric as json' do
      params = {
       :start => 1335739560,
       :end => 1335740560,
       :host => 'host_a',
       :plugin => 'memory',
       :instance => '',
       :rrd => 'memory-free'
      }
      RRD.stub(:fetch).and_return(JSON.parse(api_fixture_data('host_a_memory.raw')))
      JSON.parse(get_json('/rrd_data', params).body).should == JSON.parse(api_fixture_data('host_a_memory.json'))
    end

  end


  context 'when acting as a proxy' do

    [true, false].each do |cache|
      context (cache ? "with caching enabled" : "with caching disabled") do

        before :each do
          CollectdPlot::Config.proxy = true
          CollectdPlot::Config.cache = cache
          CollectdPlot::RRDRemote.stub!(:http_get_json).with("192.168.50.16/hosts").and_return(['bam', 'baz'])
          CollectdPlot::RRDRemote.stub!(:http_get_json).with("192.168.50.17/hosts").and_return(['bar', 'foo'])
        end

        it 'should return the union of the hosts on all shards' do
          JSON.parse(get_json('/hosts').body).sort.should == ['bam', 'bar', 'baz', 'foo']
        end

        it 'should return a mapping from shard to hosts' do
          res = JSON.parse(get_json('/shards').body)
          res.should == { '192.168.50.16' => ['bam', 'baz'], '192.168.50.17' => ['bar', 'foo'] }
        end

        it 'should return a map of hosts to shards' do
          res = JSON.parse(get_json('/host_to_shards').body)
          res.should == { 'bam' => ['192.168.50.16'], 'baz' => ['192.168.50.16'], 'bar' => ['192.168.50.17'], 'foo' => ['192.168.50.17']}
        end

        it 'should correctly map hosts to shards' do
          CollectdPlot::RRDRemote.shard_for_host('bam').should == "192.168.50.16"
          CollectdPlot::RRDRemote.shard_for_host('foo').should == "192.168.50.17"
          lambda { CollectdPlot::RRDRemote.host_for_shard('does_not_exist') }.should raise_error
        end

        it 'should find metrics for a host by asking a persistence shard' do
          mock_response = {'foo' => 'bar'}
          CollectdPlot::RRDRemote.stub!(:http_get_json).with("192.168.50.16/host/bam").and_return(mock_response)
          JSON.parse(get_json("/host/bam").body).should == mock_response
        end

        it 'should service API requests by forwarding to a persistence shard' do
          params = {
            :start => 1335739560,
            :end => 1335740560,
            :host => 'host_a',
            :plugin => 'memory',
            :instance => '',
            :rrd => 'memory-free',
            :value => 'value'
          }
          resp = JSON.parse(api_fixture_data("host_a_memory.json"))
          CollectdPlot::RRDRemote.stub!(:http_get_json).and_return(resp)
          JSON.parse(get_json("/rrd_data", params).body).should == resp
        end

        it 'should retrieve rrd files from the appropriate shard for a host' do
          rrd_data = "some binary blob"
          CollectdPlot::RRDRemote.stub!(:http_get).and_return(rrd_data)
          get_json("/rrd/baz/cpu/0/cpu-idle").body.should == rrd_data
        end

      end
    end
  end

end
