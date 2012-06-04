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
      res = CollectdPlot::Cache.instance.get("hosts_for_shard.#{s}", 600) do
        http_get_json("#{s}/hosts").to_json
      end
      JSON.parse res
    end

    def self.shard_for_host(h)
      res = CollectdPlot::Cache.instance.get("shard_for_host.#{h}")
      return res if res
      update_shards!
      CollectdPlot::Cache.instance.get("shard_for_host.#{h}")
    end

    def self.rrd_file(host, plugin, instance, rrd)
      shard = shard_for_host(host)
      uri = "#{shard}/rrd/#{host}/#{plugin}/#{instance}/#{rrd}"
      CollectdPlot::Cache.instance.get("rrd.#{uri}") do
        http_get(uri)
      end
    end

    def self.http_get_json(uri)
      JSON.parse(http_get uri, :headers => {:ccept => 'application/json'})
    end

    def self.http_get(uri, opts)
      resp = HTTParty.get uri, opts
      raise "bad response for #{uri}" unless resp.code == 200
      resp.body
    end

    def self.cache_put_hosts_for_shard(shard, hosts)
      key = "hosts_for_shard.#{shard}"
      CollectdPlot::Cache.instance.put(key, hosts.to_json, 600)
    end

    def self.cache_put_shard_for_host(host, shard)
      key = "shard_for_host.#{host}"
      CollectdPlot::Cache.instance.put(key, shard, 600)
    end

  end
end
