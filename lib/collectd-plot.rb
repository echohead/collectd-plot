$: << File.dirname(__FILE__)
require 'haml'
require 'json'
require 'pathname'
require 'sinatra'
require 'collectd-plot/cgp'
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
    helpers Sinatra::LinkToHelper, Sinatra::RespondWithHelper, Sinatra::MultipleParamValues

#set :raise_errors, true
#set :show_exceptions, false

    # if configured as a proxy, serve rrd files from remote hosts
    # else, serve rrd files from local filesystem.
    def rrd_reader
      CollectdPlot::Config.proxy ? RRDRemote : RRDRead
    end

    get '/' do
      redirect '/hosts'
    end

    get '/hosts' do
      respond_with_key :index, :hosts, :hosts => rrd_reader.list_hosts(params[:regexp]).sort, :regexp => params[:regexp]
    end

    # list metrics for host
    get '/host/:h' do |h|
      respond_with_key :host, :metrics, :host => h, :metrics => rrd_reader.list_metrics_for(h)
    end

    # show a plugin in the ui, or list plugin instances in json
    get '/host/:h/plugin/:p' do |h, p|
      respond_with_key :metric, :instances, :host => h, :plugin => p, :instances => rrd_reader.list_instances_for(h, p)
    end

    # return an entire rrdfile
    get '/rrd/:h/:p/:i/:r' do |h, p, i, r|
      rrd_reader.rrd_file(h, p, i, r)
    end

    get '/rrd_data' do
      respond_with :data, rrd_reader.rrd_data(params[:host], params[:plugin], params[:instance], params[:rrd], params[:value], params[:start], params[:end])
    end

    # return rrdtool graph
    get '/graph' do
      content_type 'image/png'
      params = request_params # handle multiple series
      if CollectdPlot::Config.proxy
        RRDRemote.http_get("http://" + RRDRemote.shards_for_host(params[:host]).first + request.env['REQUEST_URI'])
      else
        RRDGraph.graph(params)
      end
    end

    # backwards-compatibility CGP graph path
    get '/cgp/graph.php' do
      params = CollectdPlot::CGP.convert request_params
      content_type 'image/png'
      RRDGraph.graph(params)
    end

    # form to customize a graph
    get '/graph_edit' do
      params = request_params # handle multiple series
      params[:end] ||= 'now'
      params[:start] ||= 'end-24h'
      respond_with_key :graph_edit, :params, :params => params, :series => CollectdPlot::Plugins.series_for(params)
    end

    # return index of shards => hosts
    get '/shards' do
      respond_with :shard, rrd_reader.shard_index
    end

    # return and index of hosts => shards
    get '/host_to_shards' do
      respond_with :hosts, rrd_reader.hosts_to_shards
    end

    get '/sandbox' do
      data = rrd_reader.list_metrics_for('host_a')
      data.inspect
    end
  end

end
