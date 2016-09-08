module DistributedSearch
  class SearchEngine
    attr_reader :url
    attr_accessor :active

    def initialize(url)
      @url    = url
      @active = true
    end

    def inactive?
      !active
    end

    def inactivate
      self.active = false
    end

    def search(query)
      r = request(query)
      inactivate if r.nil?
      r
    end

    private

    def test_connection
      self.active = false if request('dogs').nil?
    end

    def filtered_query(query)
      "#{query} -host:linkedin.com -site:linkedin.com"
    end

    def request(query)
      params   = {q: filtered_query(query), format: :json, engines: :google}
      full_url = "#{url}?#{params.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')}"
      uri      = URI(full_url)

      begin
        Net::HTTP.start(uri.host, uri.port,
                        use_ssl: uri.scheme == 'https',
                        verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|

          request = Net::HTTP::Get.new uri.request_uri
          response = http.request request

          return JSON.parse(response.body)
        end
      rescue StandardError => e
        inactivate
      end

      nil
    end
  end
end
