unit_tests do

  test "run config" do
    assert_nothing_raised do
     result_data = Monitoring::Daemon.run_config(TEST_CONFIG)
     assert_not_nil result_data
     assert_kind_of Hash, result_data  
     assert result_data.key?(:http)
     assert result_data[:http].kind_of?(Array)
     results = result_data[:http]
     assert_kind_of Array, results
     assert results.length > 0
     assert result_data.key?(:ping)
 
    end
    
  end

end