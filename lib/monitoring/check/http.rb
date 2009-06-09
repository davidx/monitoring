require 'httparty'
module Monitoring
  module Check
    class HTTP < BASE
      include HTTParty
      def self.run(options)
        required_argument :url, options
        begin
          p "get #{options[:url]}"
          response = get(options[:url])
        rescue => e

        end
        Result.new( :body => response, :error => e, :check => self )
      end
    end
  end
end