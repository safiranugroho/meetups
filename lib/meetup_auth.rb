require 'sinatra/base'
require 'dotenv/load'
require 'net/http'
require 'uri'
require 'json'

module WeeklyMeetups
  class MeetupAuth < Sinatra::Application
    enable :sessions

    get '/authorize-meetup' do
      redirect 'https://secure.meetup.com/oauth2/authorize'\
              "?client_id=#{ENV['MEETUP_CLIENT_ID']}"\
              '&response_type=code'\
              "&redirect_uri=#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback"
    end

    get '/authorize-meetup-callback' do
      puts "Meetup.com authorized- #{params[:code]}"

      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      request_body = URI.encode_www_form(
        client_id: ENV['MEETUP_CLIENT_ID'],
        client_secret: ENV['MEETUP_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        redirect_uri: "#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback",
        code: params[:code]
      )

      uri = URI.parse('https://secure.meetup.com/oauth2/access')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = request_body

      response = http.request(request)

      puts "Meetup.com access token- #{response.body}"
    end
  end
end
