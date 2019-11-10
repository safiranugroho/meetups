require 'sinatra/base'
require 'sinatra/reloader'

require './lib/email_routes.rb'
require './lib/meetup_routes.rb'

module WeeklyMeetups
  class App < Sinatra::Application
    configure :development do
      register Sinatra::Reloader
    end

    set :root, File.dirname(__FILE__)
    set :views, settings.root + '/views'

    use EmailRoutes
    use MeetupRoutes

    get '/' do
      redirect 'https://secure.meetup.com/oauth2/authorize'\
              "?client_id=#{ENV['MEETUP_CLIENT_ID']}"\
              '&response_type=code'\
              "&redirect_uri=#{ENV['MEETUP_CALLBACK_HOST']}/fetch-meetups"
    end
  end
end
