$:.unshift(File.dirname(__FILE__) + '/lib/')

require 'test/unit'
require 'rubygems'
require 'dust'
require 'activesupport'
require 'httparty'
require 'monitoring'


Settings = { :status => { :ok =>        {:severity => 0 },
                          :warning =>   {:severity => 1 },
                          :critical =>  {:severity => 2 },
                          :unknown =>   {:severity => 1 }
} }
