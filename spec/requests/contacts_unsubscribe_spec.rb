require "rails_helper"

RSpec.describe "Contacts unsubscribe", type: :request do
  let!(:contact) { create(:contact, email: "alex@example.com", unsubscribed: false) }

  def form_action(html, button_label: nil)
    doc  = Nokogiri::HTML.parse(html)
    form = if button_label
      # find the form that contains a submit with this exact label
      doc.css("form").find do |f|
        f.css("input[type=submit],button[type=submit]").any? { |b| b["value"] == button_label || b.text.strip == button_label }
      end
    else
      doc.at_css("form")
    end
    raise "Form not found" unless form
    action = form["action"]
    method = (form["method"] || "get").downcase
    [action, method]
  end

  describe "unsubscribe flow via the GET confirmation page" do
    it "GET confirm → POST unsubscribe → shows success with a POST resubscribe button, which works" do
      get "/contacts/#{contact.id}/unsubscribe"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Unsubscribe from Replicate")
      expect(response.body).to include(contact.email)

      action, method = form_action(response.body, button_label: "Unsubscribe")
      expect(action).to eq("/contacts/#{contact.id}/unsubscribe")
      expect(method).to eq("post")

      post action
      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(true)
      expect(response.body).to include("You have unsubscribed.")
      expect(response.body).to include(contact.email)

      action2, method2 = form_action(response.body, button_label: "Resubscribe")
      expect(action2).to eq("/contacts/#{contact.id}/resubscribe")
      expect(method2).to eq("post")

      post action2
      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(false)
      expect(response.body).to include("You have resubscribed.")
      expect(response.body).to include(contact.email)
    end
  end

  describe "resubscribe flow via the GET confirmation page" do
    it "GET confirm → POST resubscribe → shows success with a link back to unsubscribe, which we then confirm" do
      contact.update!(unsubscribed: true)

      get "/contacts/#{contact.id}/resubscribe"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Resubscribe to Replicate")
      expect(response.body).to include(contact.email)

      action, method = form_action(response.body, button_label: "Resubscribe")
      expect(action).to eq("/contacts/#{contact.id}/resubscribe")
      expect(method).to eq("post")

      post action
      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(false)
      expect(response.body).to include("You have resubscribed.")
      expect(response.body).to include(contact.email)

      doc = Nokogiri::HTML.parse(response.body)
      link = doc.at_css(%Q{a[href="/contacts/#{contact.id}/unsubscribe"]})
      expect(link).to be_present

      get link["href"]
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Unsubscribe from Replicate")

      action2, method2 = form_action(response.body, button_label: "Unsubscribe")
      expect(action2).to eq("/contacts/#{contact.id}/unsubscribe")
      expect(method2).to eq("post")

      post action2
      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(true)
      expect(response.body).to include("You have unsubscribed.")
    end
  end

  describe "missing IDs" do
    it "GET /contacts/:id/unsubscribe → redirects to root when not found" do
      get "/contacts/999999999/unsubscribe"
      expect(response).to redirect_to(root_path)
    end

    it "GET /contacts/:id/resubscribe → redirects to root when not found" do
      get "/contacts/999999999/resubscribe"
      expect(response).to redirect_to(root_path)
    end

    it "POST /contacts/:id/unsubscribe → redirects to root when not found" do
      post "/contacts/999999999/unsubscribe"
      expect(response).to redirect_to(root_path)
    end

    it "POST /contacts/:id/resubscribe → redirects to root when not found" do
      post "/contacts/999999999/resubscribe"
      expect(response).to redirect_to(root_path)
    end
  end
end