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
        redirect_uri: "#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback",
        code: code
      )

      uri = URI.parse('https://secure.meetup.com/oauth2/access')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = request_body

      response = http.request(request)
      response.body
    end

    def get_events_by_group(group, number_of_extra_days = 7)
      meetup_latest_date = (Date.today + number_of_extra_days).iso8601

      uri = URI.parse("https://api.meetup.com/#{group}/events?no_later_than=#{meetup_latest_date}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      response.body
    end
  end
end
