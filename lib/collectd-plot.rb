$: << File.dirname(__FILE__)
require 'haml'
require 'json'
require 'pathname'
require 'sinatra'
require 'collectd-plot/config'
require 'collectd-plot/helpers'
require 'collectd-plot/rrd_graph'
require 'collectd-plot/rrd_read'
require 'collectd-plot/rrd_remote'

module CollectdPlot

  class Service < Sinatra::Base
    @root = Pathname.new(File.dirname(__FILE__)).parent.expand_path
    set :public_folder, @root.join('lib/collectd-plot/public')
    set :views,         @root.join('lib/collectd-plot/views')
    helpers Sinatra::LinkToHelper
    helpers Sinatra::RespondWithHelper

    # if configured as a proxy, serve rrd files from remote hosts
    # else, serve rrd files from local filesystem.
    def rrd_reader
      CollectdPlot::Config.proxy ? RRDRemote : RRDRead
    end


    get '/' do
      redirect '/hosts'
    end

    get '/hosts' do
      respond_with :index, :hosts, :hosts => rrd_reader.list_hosts.sort
    end

    # list metrics for host
    get '/host/:h' do |h|
      respond_with :host, :metrics, :host => h, :metrics => rrd_reader.list_metrics_for(h)
    end

    # show a plugin in the ui, or list plugin instances in json
    get '/host/:h/plugin/:p' do |h, p|
      respond_with :metric, :instances, :host => h, :plugin => p, :instances => rrd_reader.list_instances_for(h, p)
    end

    # return an entire rrdfile
    get '/rrd/:h/:p/:i/:r' do |h, p, i, r|
      rrd_reader.rrd_file(h, p, i, r)
    end

    # return rrdtool graph
    get '/graph' do
      content_type 'image/png'
      #RRDRead.rrd_graph(opts[:host], opts[:metric], opts[:instance], 1335739560, 1335740560, opts[:value])
      RRDGraph.graph(params)
    end

    # form to customize a graph
    get '/graph_edit' do
      params[:end] ||= 'now'
      params[:start] ||= 'end-24h'
      respond_with :graph_edit, :params, :params => params
    end

    get '/sandbox' do
      data = RRDRead.rrd_data('host_a', 'memory', 'memory-free', 1335739560, 1335740560)
      data.inspect
    end
  end

end
