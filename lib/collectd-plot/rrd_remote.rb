require 'httparty'

# get rrd data from a remote shard.


module CollectdPlot
  module RRDRemote
    include HTTParty

    def self.list_hosts()
      # TODO: check cache
      CollectdPlot::Config.rrd_servers.map { |h| hosts_for_shard(h) }.flatten
    end

    def self.hosts_for_shard(h)
      resp = HTTParty.get("#{h}/hosts.json")
      raise "bad response from #{h}" unless resp.code == 200
      JSON.parse(resp.body)
    end

  end
end
