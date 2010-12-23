
# code below taken from site: http://www.igvita.com/2010/01/28/cluster-monitoring-with-ganglia-ruby/

#(The MIT License)

#Copyright © 2009 Ilya Grigorik
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "stringio"

class XDRPacket
    def initialize
      @data = StringIO.new
    end

    def pack_uint(data)
      # big endian unsigned long
      @data << [data].pack("N")
    end
    alias :pack_int  :pack_uint

    def pack_string(data)
      len = data.size
      pack_uint(len)

      # pad the string
      len = ((len+3) / 4) * 4
      data = data + ("\0" * (len - data.size))
      @data << data
    end

    def data
      @data.string
    end
end
