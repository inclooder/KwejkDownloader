#!/usr/bin/ruby

require 'net/http'
require 'nokogiri'
require 'pathname'

HOST='kwejk.pl'
PAGESTAMP_FILE='kwejk_downloader_pagestamp'


def download_image(source, out_file)
  File.open(out_file,'w')do |f|
    uri = URI.parse(source)
    Net::HTTP.start(uri.host,uri.port)do |http| 
      resp = http.get(uri.path) 
      open(out_file, "wb") do |file|
        file.write(resp.body)
      end

    end
  end

end

def get_max_page
  Net::HTTP.start(HOST) do |http|
    resp = http.get("/strona/9999999999999999999999999999999") #szykamy najwiekszej strony
    if resp.code == '404'
      puts 'page not found 404 :('
      return 0
    end
    dom = Nokogiri::HTML(resp.body)
    penultimate_page_url = dom.css('a.btn-next-page').first['href']
    penultimate_page_num = Pathname.new(penultimate_page_url).basename
    return Integer(penultimate_page_num.to_s) + 1
  end
end


def process_page(page_num)
  Net::HTTP.start(HOST) do |http|
    puts "quering page #{page_num}"

    page_addr = "/strona/#{page_num}"
    resp = http.get(page_addr)
    puts "page [#{page_addr}] not found 404 :(" if resp.code == '404'
    dom = Nokogiri::HTML(resp.body)

    dom.css('div.media img').each do |img_elem|
        image_source = img_elem['src']

        file_name = Pathname.new(image_source).basename
        unless File.exists? file_name
          puts "downloading image #{image_source}"
          download_image(image_source, file_name)
        end
    end

  end
end


def check_pagestamp
  begin
    File.open(PAGESTAMP_FILE, "r") do |infile|
      line = infile.gets
      pagestamp = Integer(line)
      puts "pagestamp #{pagestamp}"
      return pagestamp
    end
  rescue Errno::ENOENT
  end

  return 1

end

def set_pagestamp(page_num)
  File.open(PAGESTAMP_FILE, 'w') {|f| f.write(String(page_num)) }
end

def start
  Net::HTTP.start(HOST) do |http|
    max_page = get_max_page()
    puts "Maximum page=#{max_page}"

    pagestamp = check_pagestamp()

    for page_num in pagestamp..max_page
      set_pagestamp(page_num)
      process_page(page_num)
    end
  end
end

begin
  start
rescue Interrupt
end
