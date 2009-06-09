$:.unshift File.dirname(__FILE__) + '/../lib'

require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/test_filter'
require File.dirname(__FILE__) + '/test_worker'
require File.dirname(__FILE__) + '/test_check'
require 'yaml'

unit_tests do

  test "show filters" do
    assert_kind_of Hash, Monitoring::FILTERS

  end

  test "can keep track" do
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

  test "Can use options to generify" do
    worker = Monitoring::Worker.new
    
    data = Hash.new
    config_options = {
                        :http => [
                                    { :url => 'http://www.example.com' },
                                    { :url => 'http://www.google.com' },
                                    { :url => 'http://www.test.com' }

                        ],
                        :ping => [  { :host => 'localhost', :time => 1 }  ],
                        :base => [  { :foo => 'bar' } ]
                     }

    config_options.each{|check,options_instances|
      data[check.to_sym] = []
      options_instances.each{|options|
        data[check.to_sym].push( worker.execute_check(check.to_sym, options) )
      }
    }
  end
end