

module CollectdPlot
  module Config
    @@data = {}

    def self.from_hash(data={})
      check_if_initialized!
      @@data = {}
      update!(data)
    end

    def self.from_file(path)
      check_if_initialized!
      @@data = {}
      update!(JSON.parse(File.read(path)))
    end

    def self.[](key)
      @@data[key.to_sym]
    end

    def self.method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      else
        self[sym]
      end
    end

    def self.clear!
      @@data = nil if defined?(@@data)
    end

  private

    def self.check_if_initialized!
      raise "already initialized" if defined?(@@data) and !@@data.nil?
    end

    def self.update!(data)
      data.each do |key, value|
        self[key] = value
      end
    end

    def self.[]=(key, value)
      if value.class == Hash
        @@data[key.to_sym] = Config.new(value)
      else
        @@data[key.to_sym] = value
      end
    end

  end
end
