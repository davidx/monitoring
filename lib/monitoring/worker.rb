module Monitoring
  class Worker
    include Observable
    
    def execute_check(name, options={})
      #p "check : " + name.to_s
      check = Monitoring::Check.const_get(name.to_s.upcase)
      result = check.run(options)
      filter_result = Monitoring::Filter.run(check.name, result)
      result.status = Monitoring::Status.new( filter_result )
      result
    end
    
  end
end

