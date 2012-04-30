$: << File.dirname(__FILE__)
require 'sinatra'
require 'haml'
require 'json'
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

# TODO: one method for json and html
# list hosts
get '/hosts.json' do
  content_type 'application/json'
  RRDRead.list_hosts.to_json
end


# list metrics for host
get '/hosts/:h.json' do |h|
  content_type 'application/json'
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
  (fstart, fend, data) = RRD.fetch('/vagrant/spec/fixtures/rrd/host_a/memory/memory-free.rrd', '--start', 0.to_s, '--end', Time.now.to_i.to_s, 'AVERAGE')
  puts fstart
  puts fend
  puts data.inspect
  'foo'
end

end
