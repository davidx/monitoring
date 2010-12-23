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


require 'test/unit'
require 'rubygems'
require 'dust'
require 'roxml'
require 'ohai'

$:.unshift(File.expand_path(File.dirname(__FILE__)) + '/../lib')

require 'discovery'

def xml_test_data(name) 
  IO.read(File.dirname(__FILE__) + '/data/' + name.to_s + '.xml')
end

def assert_respond_to_attributes(anytype, attributes)
  #print "#{anytype} + #{attributes.to_yaml}"
  assert_not_nil attributes
  assert_kind_of Array, attributes
  assert_block("#{anytype.class} not respond to attribute") do
    attributes.each do |attribute|
   assert anytype.respond_to?(attribute.to_sym), "fail: #{anytype} should respond to #{attribute.to_sym}"
    end
  end
end