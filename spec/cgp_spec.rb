require 'spec_helper'

describe 'CGP conversion' do

  it 'should translate all CGP parameters to their collectd-plot counterparts' do
    cgp = { :h => 'host_a', :p => 'cpu', :pi => '0', :s => '3600', :x => '400', :y => '200', :t => 'cpu' }
    expected = { :host => 'host_a', :plugin => 'cpu', :instance => '0', :end => 'now', :start => 'end-3600s', :width => '400', :height => '200' }
    CollectdPlot::CGP.convert(cgp).should == expected
  end

end
