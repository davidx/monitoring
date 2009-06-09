module Monitoring
  class Daemon
    def self.start(config)
      run_config(config)
    end
    def self.run_config(config)
      worker = Monitoring::Worker.new
      data = {}
      config.each do |check, check_instances|
        data[check.to_sym] = []
        check_instances.each do |check_options|
          data[check.to_sym].push(
            worker.execute_check(check.to_sym, check_options)
          )
        end
      end
      data
    end
  end
end