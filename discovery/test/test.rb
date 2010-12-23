#!/usr/bin/env ruby

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


$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'test_helper'

NMAPRUN_TESTRESULT  = Discovery::Nmaprun.from_xml(xml_test_data(:nmaprun_p22_results))
NMAPRUN_OSDETECT_TESTRESULT  = Discovery::Nmaprun.from_xml(xml_test_data(:nmaprun_osdetect_results))


unit_tests do

  test "can load xml" do

    assert_nothing_raised do
      Discovery::Nmaprun.from_xml(xml_test_data(:basicrun_noresults))
    end
    assert_not_nil NMAPRUN_TESTRESULT
    assert_kind_of Discovery::Nmaprun, NMAPRUN_TESTRESULT
  end


  test "NMAPRUN_TESTRESULT instance responds to attributes" do

    attributes = %w[
              scanner
              args
              start
              startstr
              version
              xmloutputversion
                  ]
    assert_respond_to_attributes(NMAPRUN_TESTRESULT, attributes)
  end

  test "scaninfo_instance responds to attributes" do
    scaninfo = NMAPRUN_TESTRESULT.scaninfo
    attributes = %w[
              type
              protocol
              numservices
              services
                  ]
    assert_respond_to_attributes(scaninfo, attributes)
    assert scaninfo.protocol == 'tcp'
    assert scaninfo.numservices == '1'
  end

  test "host instance responds to attributes" do
    host = NMAPRUN_TESTRESULT.hosts.first

    attributes = %w[
             starttime
             endtime
             ip
             mac
             name
             ports
             status
             state

             ]
       #       uptime  does not work yet
    assert_respond_to_attributes(host, attributes)
    assert_not_nil host
    assert_kind_of Discovery::Host, host
    assert host.respond_to?(:name)
    assert_equal 'app1', host.name
    assert_equal '172.16.32.11', host.ip
    assert_equal '00:TT:29:00:66:21', host.mac
    assert_kind_of Array, host.ports
    assert host.ports.length == 1
    assert host.ports.first.kind_of?(Discovery::Port)
    assert_kind_of Discovery::Status, host.status
    assert_equal "up", host.status.state
  #  assert_kind_of Integer, host.uptime
  end
  test "port class responds to attributes" do
    port = NMAPRUN_TESTRESULT.hosts.first.ports.first

    attributes = %w[
             service
             portid
             ]

    assert_respond_to_attributes(port, attributes)
    assert_not_nil port
    assert_kind_of Discovery::Port, port
    assert port.respond_to?(:service)
    assert port.service.respond_to?(:name)
    assert_equal 'ssh', port.service.name
    assert_equal 22, port.portid.to_i
  end

  test "runstats class responds to attributes" do
    runstats = NMAPRUN_TESTRESULT.runstats

    attributes = %w[
             finished
             hosts
             ]

    assert_respond_to_attributes(runstats, attributes)
    assert_not_nil runstats
    assert_kind_of Discovery::Runstats, runstats
    assert_equal 81, runstats.hosts.up.to_i
    assert_equal 172, runstats.hosts.down.to_i
    assert_equal 253, runstats.hosts.total.to_i                   
  end

  test "host status class responds to attributes" do
    runstats = NMAPRUN_TESTRESULT.runstats

    attributes = %w[
             finished
             hosts
             ]

    assert_respond_to_attributes(runstats, attributes)
    assert_not_nil runstats
    assert_kind_of Discovery::Runstats, runstats
    assert_equal 81, runstats.hosts.up.to_i
    assert_equal 172, runstats.hosts.down.to_i
    assert_equal 253, runstats.hosts.total.to_i


  end
  test "discovery class responds to attributes" do

    attributes = %w[
             scan_network 
             ]

    assert_respond_to_attributes(Discovery::Scan, attributes)

  end

  test "run discovery" do
    assert_raise(ArgumentError) { Discovery::Scan.scan_network() }

#    assert_nothing_raised do
#      discovery_result  = Discovery.scan_network("10.10.10.2")
#    end
  end
end