require 'distributed_search/search_engine'

module DistributedSearch
  class DistributedSearch
    attr_reader :query, :search_engines
    attr_accessor :current_search

    URLS = %w(
    https://searx.me
    https://searx.laquadrature.net
    https://searx.volcanis.me
    https://search.homecomputing.fr
    https://searx.potato.hu
    https://s3arch.eu
    https://framabee.org
    https://search.jpope.org
    https://suche.elaon.de
    https://www.searx.de
    https://www.ready.pm/
    https://searx.schrodinger.io
    https://searx.nulltime.net
    https://www.heraut.eu/search/
    https://searx.aquilenet.fr
    https://search.azkware.net
    http://s.n0.is
    https://search.alecpap.com
    https://seeks.hsbp.org
    https://searx.coding4schoki.org
    https://searx.brihx.fr
    https://search.kujiu.org
    https://searx.info
    https://searx.drakonix.net
    https://searx.netzspielplatz.de
    https://searx.32bitflo.at
  )

    def initialize
      @search_engines = []
      init_search

      @query          = query
      @current_search = search_engines.shuffle.first
    end

    def search(query)
      result = nil

      begin
        result = next_search.search(query)
      end while result.nil?

      result
    end

    private
    def next_search
      begin
        next_search_engine = search_engines.index(self.current_search) + 1
        next_search_engine = 0 if next_search_engine == search_engines.size

        self.current_search = search_engines.at(next_search_engine)
      end while self.current_search.inactive?  # Only grab an active search connection

      self.current_search
    end

    def init_search
      URLS.each { |url| @search_engines << SearchEngine.new(url) }

      @search_engines.reject! { |se| se.inactive? }
    end

  end
end