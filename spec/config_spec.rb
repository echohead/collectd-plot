require 'spec_helper'

describe 'config' do

  before :each do
    CollectdPlot::Config.clear!
  end

  it 'should allow properties to be accessed via method names' do
    CollectdPlot::Config.from_hash :foo => :bar, :baz => [1, 2]
    CollectdPlot::Config.foo.should == :bar
    CollectdPlot::Config.baz.should == [1, 2]
  end

  it 'should allow properties to be accessed via hash syntax with strings' do
    CollectdPlot::Config.from_hash :foo => :bar, :baz => [1, 2]
    CollectdPlot::Config['foo'].should == :bar
  end

  it 'should allow properties to be accessed via hash syntax with symbols' do
    CollectdPlot::Config.from_hash :foo => :bar, :baz => [1, 2]
    CollectdPlot::Config[:foo].should == :bar
  end

  it 'should be able to initialize from a json file' do
    CollectdPlot::Config.from_file("#{File.dirname(__FILE__)}/fixtures/config.json")
    CollectdPlot::Config.arbitrary_key.should == 'foobar'
  end

end
