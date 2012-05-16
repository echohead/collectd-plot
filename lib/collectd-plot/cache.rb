require 'redis'
require 'singleton'
require 'collectd-plot/config'

module CollectdPlot
  class Cache
    include Singleton

    def initialize
      @r = Redis.new :host => CollectdPlot::Config.redis_host
    end

    def put(key, value, ttl=60)
      @r[key] = value
      @r.expire key, ttl
    end

    def get(key)
      @r[key]
    end

    def delete_keys(pattern)
      @r.keys(pattern).each { |k| @r.del k }
    end

  end
end

