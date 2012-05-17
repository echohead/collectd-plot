require 'redis'
require 'singleton'
require 'collectd-plot/config'

module CollectdPlot
  class Cache
    include Singleton

    def initialize
      @r = Redis.new :host => CollectdPlot::Config.redis_host
    end

    def namespaced(key)
      "collectd-plot.#{key}"
    end

    def put(key, value, ttl=60)
      k = namespaced key
      @r[k] = value
      @r.expire k, ttl
    end

    # return the cached value, if one exists.
    # if no value exists, and a block is provided, cache the result of the block and return it.
    def get(key, ttl=60)
      k = namespaced key
      cached = @r[k]
      return cached if cached
      if block_given?
        val = yield
        put(key, val, ttl)
        val
      else
        nil
      end
    end

    def delete_keys
      @r.keys(namespaced '').each { |k| @r.del k }
    end

  end
end

