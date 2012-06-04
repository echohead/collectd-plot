require 'sinatra/base'
require 'csv'

module Sinatra
  module LinkToHelper
    # from http://gist.github.com/98310
    def link_to(url_fragment, params={})
      base = request.script_name
      if params.size > 0
        "#{base}#{url_fragment}?#{params.keys.map { |k| "#{k}=#{params[k]}" }.join('&')}"
      else
      "#{base}#{url_fragment}"
      end
    end
  end
end


module Sinatra
  module RespondWithHelper
    def respond_with_key(name, json_key, data)
      (request.accept.concat ['text/html']).each do |type|
        case type.downcase.strip
        when 'application/json'
          content_type :json
          halt data[json_key].to_json
        when 'text/csv'
          raise "CSV not implemented for this method"
        else
          content_type :html
          halt haml(name, :locals => data)
        end
      end
    end

    def respond_with(name, data)
    (request.accept.concat ['text/html']).each do |type|
        case type.downcase.strip
        when 'application/json'
          content_type :json
          halt data.to_json
        when 'text/csv'
          with_headers = [['time', 'value']].concat data
          res = CSV.generate do |csv|
            with_headers.each { |e| csv << e }
          end
          halt res
        else
          content_type :html
          halt haml(name, :locals => {:data => data})
        end
      end
    end
  end
end
