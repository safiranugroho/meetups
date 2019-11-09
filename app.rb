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
      redirect '/authorize-meetup'
    end
  end
end
