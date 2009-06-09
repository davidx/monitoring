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

