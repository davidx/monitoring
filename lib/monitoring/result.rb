module Monitoring
  class Result
    attr_reader :body, :error, :options, :check, :status, :datetime
    attr_accessor :status

    def initialize(options)
      @options = options
      options.each {|key, value| self.instance_variable_set("@#{key}", value) }
      @datetime = DateTime.now
    end

    def method_missing(name, &block)
      return @options[name] if @options.key?(name)
      raise ArgumentError, " no such method #{name}"
    end
  end
end