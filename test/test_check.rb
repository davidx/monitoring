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
  