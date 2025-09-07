# spec/requests/members_subscriptions_spec.rb
# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Members subscription flows", type: :request do
  let!(:member) { create(:member, email: "alex@example.com", subscribed: true) }

  describe "GET /members/:id/unsubscribe" do
    it "renders the unsubscribe confirmation form" do
      get "/members/#{member.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Unsubscribe from SEV-1 emails?")
      expect(response.body).to include(member.email)
      # posts to the confirm route
      expect(response.body).to include(%Q{action="/members/#{member.id}/unsubscribe"})
      expect(response.body).to include("Yes, unsubscribe")
    end

    it "redirects to root when member not found" do
      get "/members/999999999/unsubscribe"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /members/:id/unsubscribe" do
    it "marks the member unsubscribed and renders the success page" do
      post "/members/#{member.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(member.reload.subscribed).to be(false)
      expect(response.body).to include("You have unsubscribed.")
      expect(response.body).to include(member.email)
      # offers a resubscribe POST
      expect(response.body).to include(%Q{action="/members/#{member.id}/resubscribe"})
      expect(response.body).to include("Resubscribe")
    end

    it "is idempotent (already unsubscribed still returns 200)" do
      member.update!(subscribed: false)

      post "/members/#{member.id}/unsubscribe"

      expect(response).to have_http_status(:ok)
      expect(member.reload.subscribed).to be(false)
    end

    it "redirects to root when member not found" do
      post "/members/999999999/unsubscribe"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /members/:id/resubscribe" do
    it "renders the resubscribe confirmation form" do
      member.update!(subscribed: false)

      get "/members/#{member.id}/resubscribe"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Resubscribe to SEV-1 emails?")
      expect(response.body).to include(member.email)
      # posts to the confirm route
      expect(response.body).to include(%Q{action="/members/#{member.id}/resubscribe"})
      expect(response.body).to include("Yes, resubscribe")
    end

    it "redirects to root when member not found" do
      get "/members/999999999/resubscribe"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /members/:id/resubscribe" do
    it "marks the member subscribed and renders the success page" do
      member.update!(subscribed: false)

      post "/members/#{member.id}/resubscribe"

      expect(response).to have_http_status(:ok)
      expect(member.reload.subscribed).to be(true)
      expect(response.body).to include("You have resubscribed.")
      expect(response.body).to include(member.email)
      # offers a way back to unsubscribe again
      expect(response.body).to include(%Q{href="/members/#{member.id}/unsubscribe"})
      expect(response.body).to include("unsubscribe again")
    end

    it "is idempotent (already subscribed still returns 200)" do
      member.update!(subscribed: true)

      post "/members/#{member.id}/resubscribe"

      expect(response).to have_http_status(:ok)
      expect(member.reload.subscribed).to be(true)
    end

    it "redirects to root when member not found" do
      post "/members/999999999/resubscribe"
      expect(response).to redirect_to(root_path)
    end
  end
end