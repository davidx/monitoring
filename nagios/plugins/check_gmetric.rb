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

Choice.options do
  header ''
  header 'Specific options:'

  option :host, :required => true do
    short '-H'
    long '--host=HOST'
    desc 'The hostname or ip of the host to check (required)'
  end

  option :metric, :required => true do
    short '-m'
    long '--metric=METRIC'
    desc 'The metric name to check (required)'
  end
  option :threshold, :required => true do
    short '-t'
    long '--threshold=THRESHOLD'
    desc 'The threshold to apply (required)'
  end
  option :operator do
    short '-o'
    long '--operator=OPERATOR'
    desc 'The operator to apply to the threshold (default >)'
    default '>'
  end
  option :rrd_path do
    short '-r'
    long '--rrd-path=RRDPATH'
    desc 'The base rrd path, default: /var/lib/ganglia/rrds'
    default '/var/lib/ganglia/rrds'
  end
  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end
end

CLUSTER       ='prod'
HOSTNAME      =Choice.choices[:host]
METRIC        =Choice.choices[:metric]
THRESHOLD     =Choice.choices[:threshold].to_i
STALE_TIMEOUT = 900
BASE_RRD_PATH = Choice.choices[:rrd_path]
FULL_RRD_PATH = File.join(BASE_RRD_PATH, CLUSTER, HOSTNAME, METRIC) + ".rrd"
OPERATOR      =Choice.choices[:operator]

def rrdtool(cmd, file)
  command = "rrdtool #{cmd.to_s} #{file}|grep ':' "
  `#{command}`.strip
end

def get_last_update(rrd_file)
  out = rrdtool(:lastupdate, rrd_file)
  time, value = out.gsub(/\s+/, '').split(/:/)
  [time, value.to_i]
end

def exit_generic(status, message)
  print "[#{status.to_s.upcase}] HOST: #{HOSTNAME} METRIC: #{METRIC} " + message + "\n"
  exit NAGIOSMAP[status.to_s]
end

def is_stale?(time)
  DateTime.now.strftime("%s").to_i - time.to_i > STALE_TIMEOUT
end

unless File.exists?(FULL_RRD_PATH)
  exit_critical("no such rrd file : " + FULL_RRD_PATH)
end

time, value = get_last_update(FULL_RRD_PATH)

if is_stale?(time)
  exit_critical("stale data")
end

if value.send(OPERATOR, THRESHOLD)
  exit_critical("value #{value} is not (#{OPERATOR}) threshold #{THRESHOLD}!")
else
  exit_ok("value #{value} is (#{OPERATOR}) threshold #{THRESHOLD}")
end
