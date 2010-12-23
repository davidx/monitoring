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


module Discovery
  class ScanResult
    attr_reader :result

    def initialize(result_object)
      @result = result_object
      self
    end
  end

  class Scan
    def self.scan_network(network, options={})
      default_options = " --no-stylesheet -sP -T4 -r -oX  -"
      cli_options = options[:cli_options] || default_options
      command = "nmap #{cli_options} #{network}"
      xml_output =  `#{command}`
      nmaprun_result  = Discovery::Nmaprun.from_xml(xml_output)
    end
  end
  class Base
    include ROXML
  end

  class ScanInfo < Base
    xml_reader :type, :from => :attr
    xml_reader :protocol, :from => :attr
    xml_reader :numservices, :from => :attr
    xml_reader :services, :from => :attr
    xml_reader :verbose, :from => :attr
    xml_reader :debug, :from => 'level', :in => 'debugging'
  end
  class Service < Base
    xml_reader :name, :from => :attr
    xml_reader :method, :from => :attr
    xml_reader :conf, :from => :attr

  end
  class Status < Base
    xml_reader :state, :from => :attr
    xml_reader :reason, :from => :attr
  end
  class HostState < Base
    xml_reader :state, :from => :attr
    xml_reader :reason, :from => :attr
    def to_s
      state
    end
  end
  class State < Base
    xml_reader :state, :from => :attr
    xml_reader :reason, :from => :attr
    xml_reader :reason_ttl, :from => :attr
  end
  class Port < Base
    xml_reader :protocol, :from => :attr
    xml_reader :portid, :from => :attr
    xml_reader :service, :from => :content, :in => 'service', :as => Service
    xml_reader :state, :from => :content, :in => 'state', :as => State
  end
  class HostName < Base
    xml_reader :name, :from => :attr, :in => 'hostname'
    xml_reader :type, :from => :attr

  end
  class Address < Base
    xml_reader :addr, :from => :attr
    xml_reader :addrtype, :from => :attr
  end
  class Host < Base
    xml_reader :starttime, :from => :attr
    xml_reader :endtime, :from => :attr
    xml_reader :address, :from => :content, :in => 'address', :as => [Address]
    xml_reader :hostnames, :from => :content, :in => 'hostnames', :as => HostName
    xml_reader :ports, :from => 'ports', :as => [Port]
    xml_reader :status, :from => :content, :in => 'status', :as => Status
  #  xml_reader :uptime, :from => :attr, :in => 'seconds', :as => Integer

    def state
      status.state
    end
    def name
      hostnames.blank? ? "" : hostnames.name
    end

    def ip
      address.first.addr
    end

    def mac
      address[1].blank? ? "" : address[1].addr
    end
  end
  class HostStats < Base
    xml_reader :up, :from => :attr
    xml_reader :down, :from => :attr
    xml_reader :total, :from => :attr
  end
  class Runstats < Base

    xml_reader :finished, :from => :content, :in => 'time'
    xml_reader :hosts, :from => :content, :in => 'hosts', :as => HostStats

    xml_reader :up, :from => 'hosts', :in => 'up', :as => Integer
    xml_reader :down, :from => 'hosts', :in => 'down', :as => Integer
    xml_reader :total, :from => 'hosts', :in => 'total', :as => Integer

  end
  class Nmaprun < Base

    xml_reader :scanner, :from => :attr
    xml_reader :args, :from => :attr
    xml_reader :start, :from => :attr
    xml_reader :startstr, :from => :attr
    xml_reader :version, :from => :attr
    xml_reader :xmloutputversion, :from => :attr
    xml_reader :scaninfo, :as => ScanInfo  
    xml_reader :hosts, :from => 'host', :as => [Host]
    xml_reader :runstats, :from => 'runstats', :as => Runstats


  end
#  os><portused state="open" proto="tcp" portid="80" />
#  <portused state="closed" proto="tcp" portid="1" />
#  <portused state="closed" proto="udp" portid="42314" />
#  <osclass type="WAP" vendor="2Wire" osfamily="embedded" accuracy="100" />
#  <osmatch name="2Wire 1701HG wireless ADSL modem" accuracy="100" line="67" />
#  <osmatch name="2Wire 2700HG, 2700HG-B, 2701HG-B, or RG2701HG wireless ADSL modem" accuracy="100" line="87" />
#  </os>

  class PortUsed < Base
     xml_reader :state
     xml_reader :proto
     xml_reader :portid, :as => Integer
  end
  class OsClass < Base
    xml_reader :state
    xml_reader :vendor
    xml_reader :osfamily
    xml_reader :accuracy
  end
   class OsMatch < Base
    xml_reader :name
    xml_reader :line
    xml_reader :accuracy
  end
  class Os < Base
   xml_reader :portused, :from => :content, :as => [PortUsed]
   xml_reader :osclass, :from => :content, :as => OsClass
   xml_reader :osmatch, :from => :content, :as => OsMatch
  end
end


