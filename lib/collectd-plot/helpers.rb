require 'sinatra/base'

module Sinatra
  module LinkToHelper
    # from http://gist.github.com/98310
    def link_to(url_fragment, mode=:path_only)
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
end


module Sinatra
  module RespondWithHelper
    def respond_with(name, json_key, data)
      (request.accept || ['text/html']).each do |type|
        case type
        when 'text/html'
          content_type :html
          halt haml(name, :locals => data)
        else
          content_type :json
          halt data[json_key].to_json
        end
      end
    end
  end
end
