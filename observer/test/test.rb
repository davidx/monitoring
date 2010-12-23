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

$:.unshift File.dirname(__FILE__) + '/../lib'

require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/test_filter'
require File.dirname(__FILE__) + '/test_worker'
require File.dirname(__FILE__) + '/test_check'
require File.dirname(__FILE__) + '/test_daemon'

require 'yaml'

TEST_CONFIG =  {
            :http => [
                    { :url => 'http://www.example.com' },
                    { :url => 'http://www.google.com' },
                    { :url => 'http://www.test.com' }

            ],
            :ping => [  { :host => 'localhost', :time => 1 }  ],
            :base => [  { :foo => 'bar' } ]
    }

unit_tests do

  test "show filters" do
    assert_kind_of Hash, Monitoring::FILTERS

  end

  test "can keep track in status file" do
    data = {}
    worker = Monitoring::Worker.new
    result = worker.execute_check(:ping, :host => 'example.com', :time => 1)
    assert_not_nil result
    assert result.error
    assert_kind_of Monitoring::Result, result
    assert_kind_of Monitoring::Status, result.status
    data[:ping] = []
    data[:ping].push(result)
    result = worker.execute_check(:ping, :host => 'example.com', :time => 1)
    data[:ping].push(result)

  end

  test "Can use config options hash to generify loop" do
    worker = Monitoring::Worker.new

    data = Hash.new

    TEST_CONFIG.each{|check, check_instances|
      data[check.to_sym] = []
      check_instances.each{|check_options|
        data[check.to_sym].push( worker.execute_check(check.to_sym, check_options) )
      }
    }
    
  end


  test "can use config" do
    assert Monitoring::Daemon.respond_to?(:start)
    assert Monitoring::Daemon.start(TEST_CONFIG)
  end
  test "can use status" do

     

  end
end

