require 'httparty'
require 'redis'
require 'collectd-plot/cache'

# Read RRD data from remote shards.
# cache the data in redis.

module CollectdPlot
  module RRDRemote


    def self.update_shards!
      CollectdPlot::Config.rrd_servers.each do |shard|
        hosts = http_get_json "#{shard}/hosts"
        cache_put_hosts_for_shard shard, hosts
        hosts.each { |h| cache_put_shard_for_host h, shard }
      end
    end

    def self.list_hosts()
      CollectdPlot::Config.rrd_servers.map { |h| hosts_for_shard(h) }.flatten
    end


    def self.hosts_for_shard(s)
      res = cache_get("hosts_for_shard.#{s}") do
        http_get_json("#{s}/hosts")
      end
    end

    def self.shard_for_host(h)
      res = cache_get("shard_for_host.#{h}") do
        update_shards!
        shard_for_host(h)
      end
      res.is_a?(String) ? res : res.first
    end

    def self.rrd_file(host, metric, instance)
      shard = shard_for_host(host)
      http_get("#{shard}/hosts/#{host}/metric/#{metric}/instance/#{instance}/rrd")
    end




    def self.http_get_json(uri)
      JSON.parse(http_get uri)
    end

    def self.http_get(uri)
      resp = HTTParty.get uri
      raise "bad response for #{uri}" unless resp.code == 200
      resp.body
    end

    def self.namespaced_key(key)
      "rrd_remote.#{key}"
    end

    def self.cache_put_hosts_for_shard(shard, hosts)
      key = namespaced_key "hosts_for_shard.#{shard}"
      CollectdPlot::Cache.instance.put(key, hosts)
    end

    def self.cache_put_shard_for_host(host, shard)
      key = namespaced_key "shard_for_host.#{host}"
      CollectdPlot::Cache.instance.put(key, [shard])
    end

    # return a cached value, if one exists.
    # else, cache the value returned by the block, and return it.
    def self.cache_get(key)
      full_key = namespaced_key(key)
      cached = CollectdPlot::Cache.instance.get full_key
      return JSON.parse(cached) if cached
      val = yield
      CollectdPlot::Cache.instance.put full_key, val.to_json
      val
    end

  end
end
