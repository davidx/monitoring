require 'ping'

module Monitoring
  module Check
    class PING < BASE
      def self.run(options)
        required_argument :host, options
        required_argument :time, options

        begin
          response = Ping.pingecho(options[:host], options[:time])
        rescue => e
        end
        Result.new( :body => response, :pingecho => response, :error => !response, :check => self)
      end
    end
  end
end