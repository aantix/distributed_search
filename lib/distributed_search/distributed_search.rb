require 'distributed_search/search_engine'

module DistributedSearch
  class DistributedSearch
    SEARCH_ENGINES_INDEX_PAGE = 'http://stats.searx.oe5tpo.com/'
    MAX_RETRIES               = 5

    attr_reader   :query, :agent, :debug
    attr_accessor :current_search, :urls, :retries

    def initialize(debug = false)
      @agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
      @debug          = debug

      @@search_engines||= nil
      @query           = query

      init_search
    end

    def search(query, collection_key = nil)
      self.retries = 0
      result       = nil
      retryy       = false

      begin
        self.retries+=1
        search_engine = next_search

        result  = search_engine.search(query)
        retryy  = retry?(result, collection_key)

        search_engine.inactivate if retryy
      end while retryy

      result
    end

    private
    def retry?(result, collection_key)
      return false if retries > MAX_RETRIES
      return true if result.nil?
      return true if collection_key && result[collection_key].present? && result[collection_key].empty?

      false
    end

    def next_search
      init_search(true) if refresh_search_engines?

      begin
        next_search_engine = @@search_engines.index(self.current_search) + 1
        next_search_engine = 0 if next_search_engine == @@search_engines.size

        self.current_search = @@search_engines.at(next_search_engine)
      end while self.current_search.inactive?  # Only grab an active search connection

      self.current_search
    end

    def refresh_search_engines?
      @@refreshed_at && @@refreshed_at >= 1.hours.ago
    end

    def init_search(force_refresh = false)
      if @@search_engines.nil? || force_refresh
        @@refreshed_at = Time.now

        @@search_engines  = []

        self.urls = agent.get(SEARCH_ENGINES_INDEX_PAGE).search('.label-success').collect do |l|
          (l.parent().parent().at('a') || {})['href']
        end.compact

        urls.each { |url| @@search_engines << SearchEngine.new(url, @debug) }

        @@search_engines.reject! { |se| se.inactive? }
        self.current_search = @@search_engines.shuffle.first
      end

    end
  end
end