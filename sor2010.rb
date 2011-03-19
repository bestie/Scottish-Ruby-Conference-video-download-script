require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'ostruct'

BASE_URL = 'http://video2010.scottishrubyconference.com/'
SAVE_DIR = 'scottish_ruby_conference_2010'

index_page = Nokogiri.HTML(Net::HTTP.get(URI.parse(BASE_URL)))
# get all links
links = index_page.xpath('//a')

# remove links not matching show_video
links = links.to_a.delete_if { |link| !link.attr('href').to_s.match(/show_video/) }

# create some intuitive openstructs
links = links.to_a.map { |link| OpenStruct.new(:speaker => link.parent.children.last.text, :title => link.text, :href => link.attr('href')) }

`mkdir #{SAVE_DIR}`

links.each do |link|
  video_page = Nokogiri.HTML(Net::HTTP.get(URI.parse(BASE_URL + link.href)))
  download_link = video_page.xpath('//a[contains(., "MP4")]').attr('href').to_s  
  nice_file_name = "#{link.speaker} - #{link.title}.mp4"
  `wget '#{download_link}' -O '#{SAVE_DIR}/#{nice_file_name}'`
end