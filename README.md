# weekly meetups
Displays all upcoming meetups for the next week from technology-related groups in Meetup.com in the local area (defaults to Melbourne, Australia), with the option to send them in an email (defaults to ThoughtWorks Australia mailing list).

This client consumes the data from a GraphQL server in this project: https://github.com/safiranugroho/meetups-gql.

## Getting started
Here are instructions if you want to maintain your own version of weekly meetups.

### System requirements
* Docker 18.03.1 or newer
* Java 8 or newer
* On Linux or OSX: Bash and `curl`
* On Windows: Windows 10

### Admin requirements
* Meetup.com account
* Gmail account

### Setting up OAuth credentials
1. To access the Meetup API, follow [this instruction](https://www.meetup.com/meetup_api/auth/#oauth2) to set up your own OAuth consumers.
1. Set up your OAuth client for the Gmail API by following [this instruction](https://support.google.com/googleapi/answer/6158849?hl=en&ref_topic=7013279), note to set the 'Application Type' to '**Web Application**'.
 > To access both of these APIs, I've set up two consumers: one per environment with different hostnames (http://localhost:4567 and whatever the production hostname is).

### Running the application locally
1. Make a copy of `.env.template` and rename it to `.env`
1. Update the `.env` file with the appropriate credentials and the email sender/name/recipient of your own choosing.
1. Run `./batect start` in the terminal
1. Your application should be running on `http://localhost:4567`

## Built with
* [Ruby 2.6.3](https://www.ruby-lang.org/en/)
* [Sinatra](http://sinatrarb.com/) - DSL for a quick Ruby web application
* [google-api-client](https://rubygems.org/gems/google-api-client/versions/0.11.1) - Google API client for Ruby
* [batect](https://batect.charleskorn.com/) - Build and test environments as code tool
