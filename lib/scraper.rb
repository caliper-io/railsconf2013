require 'pry'
require 'net/http'
require 'nokogiri'
require 'time'

module Scraper
  PAGES = {
    day1: "http://railsconf.com/2013/schedule?day=2013-04-29",
    day2: "http://railsconf.com/2013/schedule?day=2013-04-30",
    day3: "http://railsconf.com/2013/schedule?day=2013-05-1",
    day4: "http://railsconf.com/2013/schedule?day=2013-05-2",
    talks: "http://railsconf.com/2013/talks",
    speakers: "http://railsconf.com/2013/speakers"
  }.freeze
  DOWNLOADED_PATH = File.expand_path("../../cached-download", __FILE__)
end

module Scraper::Content
  def self.fetch
    p "Fetching content and storing"
    Scraper::PAGES.each do |page, url|
      r = Net::HTTP.get(URI.parse(url))
      # TODO: Finish off when train wifi comes back
      raise "Not fully implemented, manually download and store data for now as defined in Scraper::PAGES"
    end
  end
end

module Scraper
  class Parser
    DATES = {
      1 => "2013-04-29",
      2 => "2013-04-30",
      3 => "2013-05-01",
      4 => "2013-05-02"
    }.freeze

    attr_accessor :current_timeslot, :parsed_talks, :speakers

    def initialize
      self.speakers = {}
      self.parsed_talks = {}
    end

    def extract_speakers_info
      speakers_doc = Nokogiri::HTML(
        File.read(Scraper::DOWNLOADED_PATH + "/speakers.html")
      )

      speakers_doc.css(".speaker").each do |e|
        self.speakers[e.attribute("id").value] = e.css("p").to_xml
      end
    end

    def process
      extract_speakers_info

      # load up talk descriptions with speaker information
      talks_doc = Nokogiri::HTML(
        File.read(Scraper::DOWNLOADED_PATH + "/talks.html")
      )

      talks_doc.css(".talk").each do |e|
        parsed_talks[e.attribute("id").value] = {
          description: e.css("p").to_xml,
          title: e.css("h4").inner_text,
          speaker: {
            name: e.css("h6").inner_text,
            description: self.speakers[e.css("h6 a").attribute("href").value.split("#")[1] ] # lookup by h6 a href
           }
        }
      end

      # add schedule information
      [1, 2, 3, 4].each do |day|
        day_doc = Nokogiri::HTML(
          File.read(Scraper::DOWNLOADED_PATH + "/day#{day}.html")
        )

        day_doc.css(".inner div").each do |e|
          next if e.inner_text.empty?

          e_class = e.attribute("class").value
          if e_class == "timeslot"
            set_current_timeslot(e.css("p").inner_text, day)
          elsif e_class == "talkgroup"
            e.css(".slot").each do |slot_e|
              talk_link = slot_e.css("h5 a")

              # parse out location - set time to merge hash later...
              talk = {
                location: slot_e.css("h4").inner_text,
              }.merge(self.current_timeslot)

              if talk_link.inner_text.empty?
                # must be keynote or other note, therefore add limited information
                talk[:title] = slot_e.css("h5").inner_text
                talk[:description] = slot_e.css("p").inner_text

                parsed_talks[talk[:description]+talk[:starting_at].to_s] = talk
              else
                # find existing parsed talk
                talk_uid = talk_link.attribute("href").value.split("#")[1]
                parsed_talks[talk_uid].merge!(talk)
              end
            end
          end
        end

        break #TODO: Just process one for now
      end

      generate_json
    end

    def generate_json
      binding.pry
    end

    def found_timeslot?
      self.current_timeslot.present?
    end

    def set_current_timeslot(timeslot_range_string, day)
      return if timeslot_range_string.empty?
      time_range = timeslot_range_string.strip.split("-")
      self.current_timeslot = {
        starting_at: Time.parse(DATES[day] + " " + time_range[0]),
        ending_at: Time.parse(DATES[day] + " " + time_range[1])
      }
    end

  end
end
