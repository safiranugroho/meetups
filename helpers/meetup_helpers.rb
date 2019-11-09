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
        redirect_uri: 'http://localhost:4567/fetch-meetups',
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
      uri = URI.parse('http://localhost:4000/graphql')
      http = Net::HTTP.new(uri.host, uri.port)

      header = { 'Content-Type': 'application/json', 'Authorization': "Bearer #{access_token}" }
      body = {
        "query": '{ events'\
                    "(input: { category: \"292\", daysInAdvance: #{number_of_extra_days}  }) "\
                    '{ name day date time venue link group } '\
                  '}'
      }

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json

      response = http.request(request)
      response.body
    end

    def sort_events_by_date(events)
      events_by_date = Hash.new { |hash, key| hash[key] = [] }

      events.each do |event|
        date = event['date']
        events_by_date[date] = events_by_date[date] ? events_by_date[date].push(event) : event
      end

      events_by_date
        .sort
        .to_h
        .transform_keys { |date| Date.parse(date).strftime('%A, %d-%m-%Y') }
    end
  end
end
