require './lib/helpers.rb'

class TestHelpers
  include Helpers
end

describe 'Helpers' do
  let(:helpers) { TestHelpers.new }

  describe '#authorize' do
    let(:authorizer) { instance_double(Google::Auth::WebUserAuthorizer) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:credentials) { instance_double(Google::Auth::UserRefreshCredentials) }
    let(:fake_authorization_url) { 'fake authorization url' }

    before do
      allow(Google::Auth::WebUserAuthorizer).to receive(:new)
        .and_return(authorizer)
    end

    context 'when credentials are found' do
      subject { helpers.authorize request }
      before do
        allow(authorizer).to receive(:get_credentials)
          .with('me', request)
          .and_return(credentials)
      end

      it { is_expected.to eq credentials }
    end

    context 'when there are no credentials' do
      subject { helpers.authorize request }

      before do
        allow(authorizer).to receive(:get_credentials)
          .with('me', request)
          .and_return(nil)
      end

      before do
        allow(authorizer).to receive(:get_authorization_url)
          .with(login_hint: 'me', request: request)
          .and_return(fake_authorization_url)
      end

      it { is_expected.to eq fake_authorization_url }
    end
  end
end
