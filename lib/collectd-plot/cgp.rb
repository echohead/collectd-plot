
module CollectdPlot
  module CGP
    # convert cgp graph params to collectd-plot params
    def self.convert(params)
      {}.tap do |res|
        res[:host] = params[:h]
        res[:plugin] = params[:p]
        res[:instance] = params[:pi]
        res[:end] = 'now'
        res[:start] = "end-#{params[:s] || '3600'}s"
        res[:width] = params[:x]
        res[:height] = params[:y]
      end
    end
  end
end
