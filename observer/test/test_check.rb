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

unit_tests do

  test "execute check with error" do

    worker = Monitoring::Worker.new

    result = worker.execute_check(:http, :url => 'http://google.com')
    assert_nil result.error

    result = worker.execute_check(:http, :url => 'http://123e3d232.com')
    assert_not_nil result.error
    assert_kind_of SocketError, result.error
    result = worker.execute_check(:http, :url => 'http://google.com')
    assert_not_nil result.status
    assert_nil result.error
    
    assert_kind_of Monitoring::Status, result.status
  end

  test "execute host check" do
    worker = Monitoring::Worker.new
    result = worker.execute_check(:ping, :host => 'nonexistant', :time => 1)
    assert result.error, result.inspect

  end
  test "result with error"  do
    worker = Monitoring::Worker.new
    result = worker.execute_check(:ping, :host => 'localhsost', :time => 1)
    assert_equal true, result.error
  end
  test "result without error"  do
    worker = Monitoring::Worker.new
    result = worker.execute_check(:ping, :host => 'localhost', :time => 1)
    assert_equal false, result.error
  end

  test "execute hosts list check" do
    worker = Monitoring::Worker.new
    list = YAML.load(IO.read(File.dirname(__FILE__) + '/../config/hosts.yml'))
    list.each{|host|
      result = worker.execute_check(:ping, :host => host, :time => 1)
      assert_not_nil result
      result.status
    }

  end
end
  