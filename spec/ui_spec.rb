require 'spec_helper'

describe 'the UI' do
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
      get('/hosts').body.should =~ /host_a/
    end

    it 'should group and label hosts by the "host_groups" config property' do
      get('/hosts').body.should =~ /Hostgroup A/
    end

    it 'should filter hosts based on regexp' do
      get('/hosts', :regexp => 'host_\d+').body.should     =~ /host_23/
      get('/hosts', :regexp => 'host_\d+').body.should_not =~ /host_a/
    end

    it 'should list metrics for a host' do
      get('/host/host_a').body.should =~ /df/
    end

    it 'should show a graph on a metric page' do
      get('/host/host_a/plugin/load').body.should =~ /img src='\/graph\?.*host_a/
    end

    it 'should allow selection of which data to include in a graph' do
      pending 'TODO'
      body = get('/graph_edit', :host => 'host_a', :plugin => 'memory').body
      body.should =~ /include series/
      body.should =~ /memory-free/
    end

  end


  context 'when acting as a proxy' do

    before :each do
      CollectdPlot::Config.proxy = true

      CollectdPlot::RRDRemote.stub!(:http_get_json).with("http://192.168.50.16/hosts").and_return(['baz', 'bam'])
      CollectdPlot::RRDRemote.stub!(:http_get_json).with("http://192.168.50.17/hosts").and_return(['bar', 'foo'])
    end

    it 'should return the union of the hosts on all shards' do
      body = get('/hosts').body
      ['bam', 'bar', 'baz', 'foo'].each { |h| body.should =~ Regexp.new(h) }
    end

  end

end
