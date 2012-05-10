require 'httparty'
require 'redis'

# Read RRD data from remote shards.
# cache the data in redis.

module CollectdPlot
  module RRDRemote


    def self.update_shards!
      CollectdPlot::Config.rrd_servers.each do |shard|
        hosts = http_get "#{shard}/hosts.json"
        cache_put_hosts_for_shard shard, hosts
        hosts.each { |h| cache_put_shard_for_host h, shard }
      end
    end

    def self.list_hosts()
      CollectdPlot::Config.rrd_servers.map { |h| hosts_for_shard(h) }.flatten
    end


    def self.hosts_for_shard(s)
      res = cache_get("hosts_for_shard.#{s}") do
        http_get("#{s}/hosts.json")
      end
    end

    def self.shard_for_host(h)
      res = cache_get("shard_for_host.#{h}") do
        update_shards!
        shard_for_host(h)
      end
      res.is_a?(String) ? res : res.first
    end





    private

    module DummyRedis
      @@vals = {}

      def self.[]=(key, value)
        @@vals[key] = value
      end

      def self.[](key)
        @@vals[key]
      end

      def self.get(key)
        @@vals[key]
      end

      def self.keys(pattern)
        reg = Regexp.new pattern
        @@vals.keys.select { |k| k =~ reg }
      end

      def self.del(key)
        @@vals.delete key
      end
    end

    def self.http_get(uri)
      resp = HTTParty.get uri
      raise "bad response for #{uri}" unless resp.code == 200
      JSON.parse resp.body
    end

    def self.namespaced_key(key)
      "rrd_remote.#{key}"
    end

    def self.redis_conn
      if CollectdPlot::Config.cache
        Redis.new :host => CollectdPlot::Config.redis_host
      else
        DummyRedis
      end
    end

    def self.cache_put_hosts_for_shard(shard, hosts)
      key = namespaced_key "hosts_for_shard.#{shard}"
      redis_conn[key] = hosts.to_json
    end

    def self.cache_put_shard_for_host(host, shard)
      key = namespaced_key "shard_for_host.#{host}"
      redis_conn[key] = [shard].to_json
    end

    # return a cached value, if one exists.
    # else, cache the value returned by the block, and return it.
    def self.cache_get(key)
      full_key = namespaced_key(key)
      r = redis_conn
      cached = r[full_key]
      return JSON.parse(cached) if cached
      val = yield
      r[full_key] = val.to_json
      val
    end

  end
end
