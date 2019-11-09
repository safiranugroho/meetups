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

    def get_access_token(code)
      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      request_body = URI.encode_www_form(
        client_id: ENV['MEETUP_CLIENT_ID'],
        client_secret: ENV['MEETUP_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: 'http://localhost:4567/authorize-meetup-callback',
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
      uri = URI.parse("http://localhost:4000/graphql")
      http = Net::HTTP.new(uri.host, uri.port)

      header = { 'Content-Type': 'application/json', 'Authorization': "Bearer #{access_token}"}
      body = {
        "query": "{ events(input: { category: \"292\", daysInAdvance: 7  }) { name day date time venue link } }"
      }

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json

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
