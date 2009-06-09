unit_tests do

  test "run filter on result" do
    worker = Monitoring::Worker.new

    result = worker.execute_check(:http, :url => 'http://google.com')
    assert_not_nil result
    assert_kind_of Monitoring::Result, result
    assert Monitoring::Filter.respond_to?(:run)
    assert Monitoring.const_defined?("FILTERS")
    assert Monitoring::FILTERS[:http].kind_of?(Proc)
    
    status = Monitoring::Filter.run(Monitoring::FILTERS[:http], result)

  end
end