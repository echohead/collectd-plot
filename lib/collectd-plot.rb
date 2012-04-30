$: << File.dirname(__FILE__)
require 'sinatra'
require 'haml'
require 'collectd-plot/rrd_read'

module CollectdPlot

# TODO: move this helper
helpers do
 def link_to url_fragment, mode=:path_only
    case mode
    when :path_only
      base = request.script_name
    when :full_url
      if (request.scheme == 'http' && request.port == 80 ||
          request.scheme == 'https' && request.port == 443)
        port = ""
      else
        port = ":#{request.port}"
      end
      base = "#{request.scheme}://#{request.host}#{port}#{request.script_name}"
    else
      raise "Unknown script_url mode #{mode}"
    end
    "#{base}#{url_fragment}"
  end
end


# list hosts
get '/' do
  @hosts = RRDRead.list_hosts
  haml :index
end

# list metrics for host
get '/hosts/:h' do |h|
  @host = h
  @metrics = RRDRead.list_metrics_for(@host)
  haml :host
end

# get metric for host
get '/hosts/:h/metric/:m' do |h, m|
#  content_type 'image/png'
#  props = PlotProperties.new(:host => h, :metric => m)
#  data = RRDRead.get_data(props)
#  Plot.render(data, props)
end

# render a plot
get '/plot' do
#  content_type 'image/png'
#  props = PlotProperties.new(params)
#  data = RRDRead.get_data(props)
#  Plot.render(data, props)
end

get '/sandbox' do
#  content_type 'image/png'
#  CollectdPlot::Plot.example
end

end
