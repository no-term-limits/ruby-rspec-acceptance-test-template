# frozen_string_literal: true

require 'rest_client'
require 'addressable/uri'

# See: https://github.com/rest-client/rest-client for more details!
# Default open timeout and read timeout are both 60 seconds, i think, based on https://github.com/rest-client/rest-client#timeouts
module RestClientHelper
  def rest_client_request_log(http_method: 'GET', request_url: '', request_headers: {}, request_body: nil)
    DebugLogging.log_http_request(http_method: http_method, request_url: request_url, request_headers: request_headers,
                                  request_body: request_body)
  end

  def rest_client_response_log(response: nil)
    DebugLogging.log_http_response(response: response)
  end

  def rest_client_get(request_url, request_headers = {}, dont_log = nil, request_proxy = nil)
    request_url = parse_uri(request_url)
    RestClient.proxy = request_proxy
    request_headers['X-Request-ID'] ||= SecureRandom.uuid
    rest_client_request_log(http_method: 'GET', request_url: request_url, request_headers: request_headers)
    response = RestClient.get(request_url, request_headers) { |resp, _request, _result| resp }
    rest_client_response_log(response: response) unless dont_log
    response
  end

  def rest_client_post(request_url, request_body = nil, request_headers = {}, request_proxy = nil)
    request_url = parse_uri(request_url)
    RestClient.proxy = request_proxy
    request_headers['X-Request-ID'] ||= SecureRandom.uuid
    rest_client_request_log(http_method: 'POST', request_url: request_url, request_headers: request_headers,
                            request_body: request_body)
    response = RestClient.post(request_url, request_body, request_headers) { |resp, _request, _result| resp }
    rest_client_response_log(response: response)
    response
  end

  def rest_client_put(request_url, request_body = nil, request_headers = {}, request_proxy = nil)
    request_url = parse_uri(request_url)
    RestClient.proxy = request_proxy
    request_headers['X-Request-ID'] ||= SecureRandom.uuid
    rest_client_request_log(http_method: 'PUT', request_url: request_url, request_headers: request_headers,
                            request_body: request_body)
    response = RestClient.put(request_url, request_body, request_headers) { |resp, _request, _result| resp }
    rest_client_response_log(response: response)
    response
  end

  def rest_client_delete(request_url, request_headers = {}, request_body = nil, request_proxy = nil)
    request_url = parse_uri(request_url)
    request_headers['X-Request-ID'] ||= SecureRandom.uuid
    rest_client_request_log(http_method: 'DELETE', request_url: request_url, request_headers: request_headers,
                            request_body: request_body)
    response = RestClient::Request.execute(method: 'delete', url: request_url, payload: request_body,
                                           headers: request_headers, proxy: request_proxy) do |resp, _request, _result|
      resp
    end
    rest_client_response_log(response: response)
    response
  end

  def parse_uri(url)
    uri = Addressable::URI.parse(url)
    uri.to_s
  end

  def request_with_query(endpoint, query_params = {})
    parameters = begin
      query_params.to_query
    rescue StandardError
      nil
    end
    parameters.nil? || parameters.empty? ? endpoint : "#{endpoint}?#{parameters}"
  end
end
