#!/usr/bin/ruby

require 'net/http'
require 'nokogiri'
require 'pathname'
require_relative 'last_page_finder'

module KwejkDownloader
  class Program
    PAGESTAMP_FILE = 'pagestamp'.freeze

    attr_reader :out_dir

    def initialize(out_dir: './')
      @out_dir = Pathname.new(out_dir)
    end

    def download_image(source, out_file)
      uri = URI.parse(source)
      Net::HTTP.start(uri.host, uri.port) do |http|
        resp = http.get(uri.path)
        open(out_dir + out_file, 'wb') do |file|
          file.write(resp.body)
        end
      end
    end

    def process_page(page_num)
      Net::HTTP.start(KWEJK_DOMAIN) do |http|
        puts "quering page #{page_num}"

        page_addr = "/strona/#{page_num}"
        resp = http.get(page_addr)
        puts "page [#{page_addr}] not found 404" if resp.code == '404'
        dom = Nokogiri::HTML(resp.body)

        dom.css('div.media img').each do |img_elem|
          image_source = img_elem['src']

          file_name = Pathname.new(image_source).basename
          unless File.exist? file_name
            puts "downloading image #{image_source}"
            download_image(image_source, file_name)
          end
        end
      end
    end

    def read_pagestamp
      File.open(out_dir + PAGESTAMP_FILE, 'r') do |infile|
        line = infile.gets
        line.to_i
      end
    end

    def check_pagestamp
      read_pagestamp
    rescue
      1
    end

    def write_pagestamp(page_num)
      File.open(out_dir + PAGESTAMP_FILE, 'w') { |f| f.write(page_num.to_s) }
    end

    def start
      max_page = LastPageFinder.find
      puts "Maximum page=#{max_page}"

      pagestamp = check_pagestamp

      (pagestamp..max_page).each do |page_num|
        write_pagestamp(page_num)
        process_page(page_num)
      end
    end
  end
end
