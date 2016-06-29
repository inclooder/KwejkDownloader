require 'net/http'
require 'nokogiri'
require 'uri'
require_relative 'constants'

module KwejkDownloader
  class LastPageFinder
    HIGHEST_POSSIBLE_PAGE_NUMBER = 9999999999999

    def self.find
      load_page_and_find HIGHEST_POSSIBLE_PAGE_NUMBER
    end

    def self.load_page_and_find(page_number)
      load_url_and_find url_for_page(page_number)
    end

    def self.url_for_page(page_number)
      URI.join("http://#{KWEJK_DOMAIN}", '/strona/', page_number.to_s).to_s
    end

    def self.find_from_html(html)
      dom = Nokogiri::HTML(html)
      penultimate_page_url = dom.css('a.btn-next-page').first['href']
      penultimate_page_num = Pathname.new(penultimate_page_url).basename
      Integer(penultimate_page_num.to_s) + 1
    end

    def self.load_url_and_find(url)
      uri = URI.parse(url)
      body = Net::HTTP.get(uri)
      find_from_html body
    end
  end
end
