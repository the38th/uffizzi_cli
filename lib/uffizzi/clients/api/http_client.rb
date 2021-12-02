# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uffizzi/config_file'

module Uffizzi
  class HttpClient

    class << self
      def make_request(request_uri, method, require_cookies, params = {})
        uri = URI(request_uri)
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          request = build_request(uri, params, method, require_cookies)

          http.request(request)
        end

        if response.class == Net::HTTPUnauthorized
          raise StandardError.new "Not authorized"
        end
        response
      end

      private

      def build_request(uri, params, method, require_cookies)
        headers = { 'Content-Type' => 'application/json' }
        request = case method
                         when :get
                           Net::HTTP::Get.new(uri.path, headers)
                         when :post
                           Net::HTTP::Post.new(uri.path, headers)
                         when :delete
                           Net::HTTP::Delete.new(uri.path, headers)
                         when :put
                           Net::HTTP::Put.new(uri.path, headers)
                         end
        
        request["Cookie"] = ConfigFile.read_option(:cookie) if require_cookies
        request.body = params.to_json

        request
      end
    end
  end
end
