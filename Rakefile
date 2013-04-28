require 'rubygems'
require 'bundler/setup'

require 'rake'
require File.expand_path('../lib/scraper', __FILE__)

namespace :scraper do
  desc "cache and process to generate the json"
  task :cache_and_process do
    #Scraper::Content.fetch
    Scraper::Parser.new.process
    puts "Updated data/schedule.json"
  end
end
