require 'rubygems'
require 'bundler/setup'

require 'rake'
require File.expand_path('../lib/scraper', __FILE__)

namespace :scraper do
  desc "update local cache schedule information"
  task :fetch_content do
    Scraper::Content.fetch
  end

  desc "process to generate the json"
  task :process do
    Scraper::Parser.new.process
    puts "Updated data/schedule.json"
  end
end
