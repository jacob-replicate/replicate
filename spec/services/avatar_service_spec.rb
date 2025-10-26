# spec/services/avatar_service_spec.rb
require "rails_helper"

RSpec.describe AvatarService do
  describe ".avatar_row" do
    it "renders default name and photo" do
      html = described_class.avatar_row
      expect(html).to include("style='border-radius: 100%'")
      expect(html).to include("src='/logo.png'")
      expect(html).to include(">Replicate<")
      expect(html).to include("class='flex items-center gap-3'")
      expect(html).to include("class='font-medium'")
    end

    it "renders provided name and photo_path" do
      html = described_class.avatar_row(name: "Acme Corp", photo_path: "acme.png")
      expect(html).to include("src='/acme.png'")
      expect(html).to include(">Acme Corp<")
    end
  end
end