require "rails_helper"

RSpec.describe SendAdminPushNotification do
  let(:title)   { "Test Alert" }
  let(:message) { "Something important happened" }
  let(:url)     { "https://example.com/details" }

  let(:http_double)   { instance_double(Net::HTTP) }
  let(:response_double) { instance_double(Net::HTTPOK, code: "200", body: "ok") }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("PUSHOVER_API_KEY").and_return("fake-api-key")
    allow(ENV).to receive(:[]).with("PUSHOVER_USER_KEY").and_return("fake-user-key")

    allow(Net::HTTP).to receive(:new).with("api.pushover.net", 443).and_return(http_double)
    allow(http_double).to receive(:use_ssl=).with(true)
    allow(http_double).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
    allow(http_double).to receive(:start).and_yield(http_double)
    allow(http_double).to receive(:request).and_return(response_double)
  end

  it "sends a POST to pushover with correct form data" do
    result = described_class.call(title, message, url)

    expect(http_double).to have_received(:use_ssl=).with(true)
    expect(http_double).to have_received(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)

    expect(http_double).to have_received(:request) do |req|
      expect(req).to be_a(Net::HTTP::Post)
      expect(req.path).to eq("/1/messages.json")

      form_data = URI.decode_www_form(req.body).to_h
      expect(form_data).to eq(
        "token"   => "fake-api-key",
        "user"    => "fake-user-key",
        "title"   => title,
        "message" => message,
        "url"     => url
      )
    end

    expect(result).to eq(response_double)
  end

  it "still works when url is nil" do
    described_class.call(title, message, nil)

    expect(http_double).to have_received(:request) do |req|
      form_data = URI.decode_www_form(req.body).to_h
      expect(form_data["url"]).to eq("")
    end
  end
end