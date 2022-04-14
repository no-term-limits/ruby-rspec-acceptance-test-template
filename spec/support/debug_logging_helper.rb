# frozen_string_literal: true

class DebugLogging
  class << self
    def log_http_request(http_method: 'GET', request_url: '', request_headers: {}, request_body: nil)
      string = "\nHTTP #{http_method}: #{request_url}"
      string += "\nREQUEST HEADERS:  #{request_headers}" if request_headers.any?
      if request_body
        first_bit_of_response_body_in_case_its_huge = request_body[0..10_000]
        string += "\nREQUEST_BODY:  #{first_bit_of_response_body_in_case_its_huge}"
      end
      log(string)
    end

    def log_http_response(response: nil)
      response_headers = response ? response.headers : nil
      response_body = response ? response.body : nil
      string = "CURL: #{curlify(response)}"
      string += "\nRESPONSE STATUS: #{response.code}"
      string += "\nRESPONSE HEADERS: #{response_headers}"
      string += "\nRESPONSE BODY: #{response_body}"
      log(string)
    end

    def log(message)
      debug_log_array.push(message)
    end

    def debug_log_array
      @debug_log_array ||= []
      @debug_log_array
    end

    def clear_logs
      @debug_log_array ||= []
      @debug_log_array.clear
    end

    def curlify(response)
      if response
        params = response.request.args
        # params[:payload] = JSON.parse(params[:payload])
        headers = []
        params[:headers].each do |key, value|
          headers <<
            if key == :content_type
              if %i[html plain xml].include?(value)
                "Content-Type:text/#{value}"
              else
                "Content-Type:application/#{value}"
              end
            else
              "#{key}:#{value}"
            end
        end
        final_header = ''
        headers.each { |header| final_header += "--header '#{header}' " }

        "curl --url '#{params[:url]}' --request #{params[:method].upcase} --data '#{params[:payload]}' #{final_header}"
      else
        'Could not curlify: no @response. maybe tully failed or something before we managed to send off the spectrum request'
      end
    end
  end
end
