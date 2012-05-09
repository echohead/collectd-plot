$: << File.dirname(__FILE__)
require 'haml'
require 'json'
require 'pathname'
require 'sinatra'
require 'collectd-plot/helpers'
require 'collectd-plot/rrd_read'
require 'collectd-plot/rrd_remote'

module CollectdPlot

  class Service < Sinatra::Base
    @root = Pathname.new(File.dirname(__FILE__)).parent.expand_path
    set :public_folder, @root.join('lib/collectd-plot/public')
    set :views,         @root.join('lib/collectd-plot/views')
    helpers Sinatra::LinkToHelper


    def rrd_reader
      CollectdPlot::Config.proxy ? RRDRemote : RRDRead
    end


    # list hosts
    get '/' do
      @hosts = RRDRead.list_hosts
      haml :index
    end

    # TODO: one method for json and html
    # list hosts
    get '/hosts.json' do
      content_type :json
      rrd_reader.list_hosts.sort.to_json
    end


    # list metrics for host
    get '/hosts/:h.json' do |h|
      content_type :json
      @host = h
      RRDRead.list_metrics_for(@host).to_json
    end

    # list metrics for host
    get '/hosts/:h' do |h|
      @host = h
      @metrics = RRDRead.list_metrics_for(@host).sort
      haml :host
    end

    # list instance for host
    get '/hosts/:h/metric/:m' do |h, m|
      @host = h
      @metric = m
      @instances = RRDRead.list_instances_for(@host, @metric).sort
      haml :metric
    end

    # return an entire rrdfile
    get '/hosts/:h/metric/:m/instance/:i/rrd' do |h, m, i|
      content_type 'application/octet-stream'
      RRDRead.rrd_file(h, m, i)
    end

# return rrd graph
    get '/hosts/:h/metric/:m/instance/:i/graph' do |h, m, i|
      content_type 'image/png'
      value = "value" 
      if(m == "load")
        value = "shortterm"
      end
      RRDRead.rrd_graph(h, m, i, 1335739560, 1335740560, value)
    end

    get '/sandbox' do
      data = RRDRead.rrd_data('host_a', 'memory', 'memory-free', 1335739560, 1335740560)
      data.inspect
    end
  end

end
