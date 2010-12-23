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

  test "create worker" do
    worker = Monitoring::Worker.new
    assert_not_nil worker
    assert_kind_of Monitoring::Worker, worker
    assert worker.respond_to?(:execute_check)
  end
  test "execute check" do
    worker = Monitoring::Worker.new

    assert_raise(ArgumentError) do
      worker.execute_check(:http, :bogus => 'http://google.com')
    end
    assert_nothing_raised do
      worker.execute_check(:http, :url => 'http://google.com')
    end
    assert_nothing_raised do
      worker.execute_check(:http, :url => 'http://123e3d232.com')
    end

    result = worker.execute_check(:http, :url => 'http://123e3d232.com')
    assert_not_nil result
    assert_kind_of Monitoring::Result, result
  end
end 

