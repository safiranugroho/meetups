require "./helpers.rb"

class TestHelpers
  include Helpers
end

describe "Helpers" do
  let(:helpers) { TestHelpers.new }

  describe "#authorize" do
    let(:authorizer) { instance_double(Google::Auth::WebUserAuthorizer) }
    let(:request) { instance_double(Sinatra::Request) }
    let(:credentials) { instance_double(Google::Auth::UserRefreshCredentials) }
    let(:fake_authorization_url) { "fake authorization url" }

    before { allow(Google::Auth::WebUserAuthorizer).to receive(:new).and_return(authorizer) }

    context "when credentials are found" do
      subject { helpers.authorize request }
      before { allow(authorizer).to receive(:get_credentials).with("me", request).and_return(credentials) }
      it { is_expected.to eq credentials }
    end

    context "when there are no credentials" do
      subject { helpers.authorize request }
      before { allow(authorizer).to receive(:get_credentials).with("me", request).and_return(nil) }
      before { allow(authorizer).to receive(:get_authorization_url).with(login_hint: "me", request: request).and_return(fake_authorization_url) }

      it { is_expected.to eq fake_authorization_url }
    end
  end
end
