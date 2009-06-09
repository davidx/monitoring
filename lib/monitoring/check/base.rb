module Monitoring
  module Check
    class BASE      
      def self.run(options)
        required_argument :foo, options

        begin
          response = true
        rescue => e
          
        end
        Result.new( :body => response, :error => e, :check => self)
      end
    
      def self.required_argument(required, options)
        raise ArgumentError unless options.keys.include?(required)
      end
    end
  end
end