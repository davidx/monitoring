module Monitoring
  FILTERS = { }
  class Filter
    def self.define(name, &block)
      filters[name] = block
    end
    def self.run(name, result)
      filters.key?(name) ? filters[name].call : false
    end
    def self.filters
      Monitoring::FILTERS
    end
  end
end

def ok(message="")
  generic("OK " + message)
  set_status(:ok)
end

def critical(message="")
  generic("CRITICAL " + message)
  set_status(:critical)
end

def warning(message="")
  generic("WARNING " + message)
  set_status(:warning)
end

def generic(message)
  p message
end


Monitoring::Filter.define :default do
  critical("error") if result[:error]
end

Monitoring::Filter.define :ping do
  critical("no response") unless result[:pingecho]
  critical("time threshold > 2") if result[:time] > 2
  warning("time exceeds threshold") if result[:time] > 1
  critical("no result[:pingecho]") unless result[:pingecho]
  ok
end

Monitoring::Filter.define :http do
  critical("error") if result[:error]
  warning("no body found") unless result[:body]
  ok
end

