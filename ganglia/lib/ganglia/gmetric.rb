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

require "socket"

module Ganglia
  def self.gmetric(options={})
    options["type"] = "uint32" if (!options.key?("type") and !options.key?(:type))
    command = "gmetric"
    options.each { |k, v|
      command << ' --' + k.to_s + '="' + v.to_s + '"'
    }
    print command + "\n" if ENV.key?('GMETRICS_DEBUG')
    print `#{command}`
  end

# code below taken from site: http://www.igvita.com/2010/01/28/cluster-monitoring-with-ganglia-ruby/
#
#  (The MIT License)
# Copyright © 2009 Ilya Grigorik
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  class GMetric

    SLOPE = {
        'zero'        => 0,
        'positive'    => 1,
        'negative'    => 2,
        'both'        => 3,
        'unspecified' => 4
    }

    def self.send(host, port, metric)
      gmetric = self.pack(metric)

      if defined?(EventMachine) and EventMachine.reactor_running?
        # open an ephemereal UDP socket since
        # we do not plan on recieving any data
        conn = EM.open_datagram_socket('', 0)

        conn.send_datagram gmetric[0], host, port
        conn.send_datagram gmetric[1], host, port
      else
        conn = UDPSocket.new
        conn.connect(host, port)

        conn.send gmetric[0], 0
        conn.send gmetric[1], 0
      end
    end

    def self.pack(metric)
      metric = {
          :hostname => '',
          :group    => '',
          :spoof    => 0,
          :units    => '',
          :slope    => 'both',
          :tmax     => 60,
          :dmax     => 0
      }.merge(metric)

      # convert bools to ints
      metric[:spoof] = 1 if metric[:spoof].is_a? TrueClass
      metric[:spoof] = 0 if metric[:spoof].is_a? FalseClass

      raise "Missing key, value, type" if not metric.key? :name or not metric.key? :value or not metric.key? :type
      raise "Invalid metric type" if not %w(string int8 uint8 int16 uint16 int32 uint32 float double).include? metric[:type]

      meta = XDRPacket.new
      data = XDRPacket.new

      # METADATA payload
      meta.pack_int(128) # gmetadata_full
      meta.pack_string(metric[:hostname]) # hostname
      meta.pack_string(metric[:name].to_s) # name of the metric
      meta.pack_int(metric[:spoof].to_i) # spoof hostname flag

      meta.pack_string(metric[:type].to_s) # one of: string, int8, uint8, int16, uint16, int32, uint32, float, double
      meta.pack_string(metric[:name].to_s) # name of the metric
      meta.pack_string(metric[:units].to_s) # units for the value, e.g. 'kb/sec'
      meta.pack_int(SLOPE[metric[:slope]]) # sign of the derivative of the value over time, one of zero, positive, negative, both, default both
      meta.pack_uint(metric[:tmax].to_i) # maximum time in seconds between gmetric calls, default 60
      meta.pack_uint(metric[:dmax].to_i) # lifetime in seconds of this metric, default=0, meaning unlimited

      ## MAGIC NUMBER: equals the elements of extra data, here it's 1 because I added Group.
      meta.pack_int(1)

      ## METADATA EXTRA DATA: functionally key/value
      meta.pack_string("GROUP")
      meta.pack_string(metric[:group].to_s)

      # DATA payload
      data.pack_int(128+5) # string message
      data.pack_string(metric[:hostname].to_s) # hostname
      data.pack_string(metric[:name].to_s) # name of the metric
      data.pack_int(metric[:spoof].to_i) # spoof hostname flag
      data.pack_string("%s") #
      data.pack_string(metric[:value].to_s) # value of the metric

      [meta.data, data.data]
    end
  end


end
