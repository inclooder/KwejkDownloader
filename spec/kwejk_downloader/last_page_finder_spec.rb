require 'rspec'
require_relative '../../lib/kwejk_downloader/last_page_finder'

include KwejkDownloader

RSpec.describe LastPageFinder do
  let(:valid_html) {
    '<div><a class="btn-next-page" href="http://somedomain.pl/pages/89"></a></div>'
  }

  describe '.find' do
    it 'calls load_page_and_find with HIGHEST_POSSIBLE_PAGE_NUMBER' do
      expect(LastPageFinder).to receive(:load_page_and_find).with(LastPageFinder::HIGHEST_POSSIBLE_PAGE_NUMBER)
      LastPageFinder.find
    end
  end

  describe '.find_from_html' do
    it 'returns penultimate page number increased by 1' do
      expect(LastPageFinder.find_from_html valid_html).to eq 90
    end
  end

  describe '.load_url_and_find' do
    it 'downloads the page and calls find_from_html with response body' do
      resp = instance_double('Net::HTTPResponse')
      expect(Net::HTTP).to receive(:get).with(kind_of(URI)).and_return(resp)
      expect(LastPageFinder).to receive(:find_from_html)
      LastPageFinder.load_url_and_find 'http://somedomain.pl/asdfff/fda'
    end
  end

  describe '.url_for_page' do
    it 'build absolute page url' do
      expect(LastPageFinder.url_for_page(41)).to eq 'http://kwejk.pl/strona/41'
    end
  end
end
