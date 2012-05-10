require 'sinatra/base'

module Sinatra
  module LinkToHelper
    # from http://gist.github.com/98310
    def link_to(url_fragment, params={})
      base = request.script_name
      if params.size > 0
        "#{base}#{url_fragment}?#{params.keys.map { |k| "#{k}=#{params{k}}" }.join('&')}"
      end
      "#{base}#{url_fragment}"
    end
  end
end


module Sinatra
  module RespondWithHelper
    def respond_with(name, json_key, data)
      (request.accept.concat ['text/html']).each do |type|
        case type.downcase
        when 'application/json'
          content_type :json
          halt data[json_key].to_json
        else
          content_type :html
          halt haml(name, :locals => data)
        end
      end
    end
  end
end
