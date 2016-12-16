#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.article-content table tr').drop(1).each do |tr|
    next if tr.text.tidy.empty?
    td = tr.css('td')
    data = { 
      id: td[0].text.tidy,
      name: td[1].text.tidy.sub(/hon. /i, ''),
      area: td[2].text.tidy,
      term: 2005,
      source: url.to_s,
    }
    ScraperWiki.save_sqlite([:id, :name, :term], data)
  end
end

scrape_list('http://somalilandparliament.net/index.php/members-of-the-hor/65-members-by-constituency-a-party/56-members-of-the-parliament')
