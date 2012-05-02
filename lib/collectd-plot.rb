$: << File.dirname(__FILE__)
require 'haml'
require 'json'
require 'pathname'
require 'sinatra'
require 'collectd-plot/helpers'
require 'collectd-plot/rrd_read'

module CollectdPlot

  class Service < Sinatra::Base
    @root = Pathname.new(File.dirname(__FILE__)).parent.expand_path
    set :public_folder, @root.join('lib/collectd-plot/public')
    set :views,         @root.join('lib/collectd-plot/views')
    helpers Sinatra::LinkToHelper

    # list hosts
    get '/' do
      @hosts = RRDRead.list_hosts
      haml :index
    end

    # TODO: one method for json and html
    # list hosts
    get '/hosts.json' do
      content_type :json
      RRDRead.list_hosts.to_json
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
      @metrics = RRDRead.list_metrics_for(@host)
      haml :host
    end

    # return an entire rrdfile
    get '/hosts/:h/metric/:m/instance/:i/rrd' do |h, m, i|
      content_type 'application/octet-stream'
      RRDRead.rrd_file(h, m, i)
    end

    get '/sandbox' do
      data = RRDRead.rrd_data('host_a', 'memory', 'memory-free', 1335739560, 1335740560)
      puts data.inspect
    end
  end

end
