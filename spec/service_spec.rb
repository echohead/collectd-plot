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
      JSON.parse(get_json('/hosts').body).should == ['host_a', 'host_b']
    end

    it 'should list metrics for a host' do
      JSON.parse(get_json('/host/host_a').body).should ==  {
        'cpu' => { '0' => ['cpu'] },
        'df' => { 'root' => [ 'df_complex' ] },
        'load' => { '' => ['load'] },
        'memory' => { '' => ['memory'] }
      }
    end

    it 'should list instances for a metric' do
      JSON.parse(get_json('/host/host_a/plugin/load').body).should == ['load']
    end

    it 'should give an empty hash for unknown hosts' do
      JSON.parse(get_json('/host/foobar').body).should == {}
    end

    it 'should return the rrd file for a given metric' do
      actual = get('/rrd/host_a/cpu/0/cpu-user').body
#      actual = get('/host/host_a/plugin/cpu/instance/0/rrd/cpu-user').body
      expected = File.read("#{File.dirname(__FILE__)}/fixtures/rrd/host_a/cpu-0/cpu-user.rrd")
      actual.should == expected
    end

    it 'should return rrd data for a host and time interval' do
      pending 'TODO'
    end

    it 'returns rrd data for a metric' do
      start = 1335739560
      stop = start + 1000
      pending 'TODO'
    end

  end


  context 'when acting as a proxy' do

    before :each do
      CollectdPlot::Config.proxy = true

      CollectdPlot::RRDRemote.stub!(:http_get_json).with("192.168.50.16/hosts").and_return(['baz', 'bam'])
      CollectdPlot::RRDRemote.stub!(:http_get_json).with("192.168.50.17/hosts").and_return(['bar', 'foo'])
    end

    it 'should return the union of the hosts on all shards' do
      JSON.parse(get_json('/hosts').body).sort.should == ['bam', 'bar', 'baz', 'foo']
    end

    it 'should correctly map hosts to shards' do
      CollectdPlot::RRDRemote.shard_for_host('bam').should == "192.168.50.16"
      CollectdPlot::RRDRemote.shard_for_host('foo').should == "192.168.50.17"
      lambda { CollectdPlot::RRDRemote.host_for_shard('does_not_exist') }.should raise_error
    end

    it 'should retrieve rrd files from the appropriate shard for a host' do
      rrd_data = "some binary blob"
      CollectdPlot::RRDRemote.stub!(:http_get).with("192.168.50.16/rrd/baz/cpu/0/cpu-idle").and_return(rrd_data)
      get_json("/rrd/baz/cpu/0/cpu-idle").body.should == rrd_data
    end

  end

end
