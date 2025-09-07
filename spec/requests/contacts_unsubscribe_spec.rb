require "rails_helper"

RSpec.describe "Contacts unsubscribe", type: :request do
  describe "GET /contacts/:id/unsubscribe" do
    let(:contact) { create(:contact, email: "alex@example.com", unsubscribed: false) }

    it "marks the contact unsubscribed and renders the confirmation page" do
      get "/contacts/#{contact.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(true)

      # basic content checks
      expect(response.body).to include("You have unsubscribed")
      expect(response.body).to include(contact.email)
      expect(response.body).to include("support@replicate.info") # from your view
    end

    it "marks the contact unsubscribed and renders the confirmation page" do
      post "/contacts/#{contact.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(true)

      # basic content checks
      expect(response.body).to include("You have unsubscribed")
      expect(response.body).to include(contact.email)
      expect(response.body).to include("support@replicate.info") # from your view
    end

    it "is idempotent (already unsubscribed still returns 200 and stays unsubscribed)" do
      contact.update!(unsubscribed: true)

      get "/contacts/#{contact.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(contact.reload.unsubscribed).to be(true)
    end

    it "redirects to root when the contact is not found" do
      get "/contacts/999999999/unsubscribe"

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end
  end
end