require 'spec_helper'

describe 'config' do

  it 'should allow properties to be accessed via method names' do
    CollectdPlot::Config.init :foo => :bar, :baz => [1, 2]
    CollectdPlot::Config.foo.should == :bar
    CollectdPlot::Config.baz.should == [1, 2]
  end

end
