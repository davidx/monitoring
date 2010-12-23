#!/usr/bin/ruby

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
require 'nagios'

require 'rubygems'
require 'choice'
require 'yaml'
require 'riddle'
require 'riddle/0.9.9'

Choice.options do
  header ''
  header 'Specific options:'

  option :host, :required => true do
    short '-H'
    long '--host=HOST'
    desc 'The hostname or ip of the host to check (required)'
  end
  option :port do
    short '-p'
    long '--port=PORT'
    desc 'The port'
  end
  option :query, :required => true do
    short '-q'
    long '--query=QUERY'
    desc 'The search query'
    default '9312'
  end
  option :timeout do
    short '-t'
    long '--tiemout=TIMEOUT'
    desc 'The response timeout'
    default '5'
  end
  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end
end

HOSTNAME=Choice.choices[:host]
PORT    =Choice.choices[:port]
QUERY   =Choice.choices[:query]
TIMEOUT =Choice.choices[:timeout]
begin
  timeout(TIMEOUT) do
    start_time        = Time.now
    client            = Riddle::Client.new HOSTNAME, PORT
    client.match_mode = :extended
    result            = client.query QUERY
    duration          = Time.now - start_time

    unless result[:status] == 0
      exit_critical("status returned other than 0 " + result.inspect)
    end
    unless result[:total] != 0
      exit_critical("0 results for  " + result.inspect)
    end
    unless result[:total_found] > 1
      exit_critical("total_found not > 1 " + result.inspect)
    end

    exit_ok("total results found #{result[:total_found]} for query #{QUERY} in #{duration} seconds")
  end
rescue
  exit_critical("error: #{$!}")
end
