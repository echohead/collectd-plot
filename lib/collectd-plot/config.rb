require 'json'

module CollectdPlot
  module Config
    @@data = {}

    def self.from_hash(data={})
      @@data = {}
      update!(data)
    end

    def self.from_file(path)
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

    def self.update!(data)
      data.each do |key, value|
        self[key] = value
      end
    end

    def self.[]=(key, value)
      @@data[key.to_sym] = value
    end

  end
end

