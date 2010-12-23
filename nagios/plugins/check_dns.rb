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


$:.unshift File.dirname(__FILE__) + '/../lib'
require 'nagios'

require 'rubygems'
require 'choice'
require 'net/dns/resolver'
require 'timeout'


Choice.options do
  header ''
  header 'Specific options:'

  option :host, :required => true do
    short '-H'
    long '--host=HOST'
    desc 'The hostname or ip of the host to check (required)'
  end
  option :query, :required => true do
    short '-q'
    long '--query=QUERY'
    desc 'The dns query, name to be resolved. (required)'
  end
  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end
end

HOSTNAME=Choice.choices[:host]
QUERY   =Choice.choices[:query]

begin
  timeout(1) do
    start_time = Time.now
    packet     = Net::DNS::Resolver.start(QUERY)
    duration   = Time.now - start_time

    exit_critical("no answer record") unless packet.answer.any?
    exit_ok("response for #{QUERY} @ #{HOSTNAME} returned in #{duration} seconds")

  end
rescue
  exit_critical("error: #{$!}")
end