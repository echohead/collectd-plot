

module CollectdPlot
  class PlotProperties
    attr_accessor :host    # may be a glob
    attr_accessor :metric
    attr_accessor :start
    attr_accessor :finish
    attr_accessor :instance

    def initialize(params = {})
      self.host = params[:host] or raise ("no host")
      self.metric = params[:metric] or raise ("no metric")
      self.instance = params[:instance]
      self.start = params[:start] || (Time.now.to_i - 86400)
      self.finish = params[:finish] || Time.now.to_i
      self.instance = params[:instance] || "TODO"
    end
  end
end
