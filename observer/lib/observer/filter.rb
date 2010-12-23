=begin
 Copyright (c) 2010 David Andersen | davidx.org | davidx at davidx.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

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

