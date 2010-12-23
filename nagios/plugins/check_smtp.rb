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
require 'net/smtp'
require 'socket'
require 'timeout'

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
    default 25
  end

  separator ''
  separator 'Common options: '

  option :help do
    long '--help'
    desc 'Show this message'
  end
end

HOSTNAME   =Choice.choices[:host]
PORT       =Choice.choices[:port]
FROM_DOMAIN="example.com"


def send_email(from, from_alias, to, to_alias, subject, message)
  msg = <<EOM
From: #{from_alias} <#{from}>
To: #{to_alias} <#{to}>
Subject: #{subject}

  #{message}
EOM

  Net::SMTP.start(HOSTNAME, PORT, FROM_DOMAIN) do |smtp|
    smtp.send_message msg, from, to
  end
end

def parse_response(response)
  status_code, version, status_string, action, as, qid = response.strip.split(/\s+/)
  {:status => status_code, :queue_id => qid, :string => status_string}
end

response        = send_email("test@example.com", "monitoring user")
parsed_response = parse_response(response)
exit_critical(response) unless parsed_response['status'].to_i == 250
exit_ok(response)

