require 'sinatra/base'
require 'dotenv/load'
require 'net/http'
require 'uri'
require 'json'

module WeeklyMeetups
  module MeetupHelpers
    def get_access_token(code)
      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      request_body = URI.encode_www_form(
        client_id: ENV['MEETUP_CLIENT_ID'],
        client_secret: ENV['MEETUP_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: "#{ENV['MEETUP_CALLBACK_HOST']}/fetch-meetups",
        code: code
      )

      uri = URI.parse('https://secure.meetup.com/oauth2/access')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = request_body

      response = http.request(request)
      response
    end

    def get_upcoming_events(access_token, number_of_extra_days = 7)
      end_range_date = (DateTime.now + number_of_extra_days).strftime('%Y-%m-%dT%H:%M:%S')

      uri = URI.parse('https://api.meetup.com/find/upcoming_events'\
        '?topic_category="292"'\
        "&end_date_range=#{end_range_date}")

      headers = { 'Authorization': "Bearer #{access_token}" }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri, headers)

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
