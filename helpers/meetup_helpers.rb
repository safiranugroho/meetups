require 'sinatra/base'
require 'dotenv/load'
require 'net/http'
require 'uri'
require 'json'

module WeeklyMeetups
  module MeetupHelpers
    def get_events_by_group(group, number_of_extra_days = 7)
      meetup_earliest_date = Date.today.iso8601
      meetup_latest_date = (Date.today + number_of_extra_days).iso8601

      uri = URI.parse("https://api.meetup.com/#{group}/events"\
        "?no_earlier_than=#{meetup_earliest_date}"\
        "&no_later_than=#{meetup_latest_date}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      response.body
    end

    def sort_events_by_date(events)
      events_by_date = Hash.new { |hash, key| hash[key] = [] }

      events.each do |event|
        date = event['local_date']
        events_by_date[date] = events_by_date[date] ? events_by_date[date].push(event) : event
      end

      events_by_date
        .sort
        .to_h
        .transform_keys { |date| Date.parse(date).strftime('%A, %d-%m-%Y') }
    end
  end
end
