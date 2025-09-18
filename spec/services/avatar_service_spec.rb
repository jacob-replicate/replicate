# spec/services/avatar_service_spec.rb
require "rails_helper"

RSpec.describe AvatarService do
  describe ".avatar_row" do
    it "renders default name and photo" do
      html = described_class.avatar_row
      expect(html).to include("style='border-radius: 100%'")
      expect(html).to include("src='/logo.png'")
      expect(html).to include(">replicate.info<")
      expect(html).to include("class='flex items-center gap-3'")
      expect(html).to include("class='font-medium'")
    end

    it "renders provided name and photo_path" do
      html = described_class.avatar_row(name: "Acme Corp", photo_path: "acme.png")
      expect(html).to include("src='/acme.png'")
      expect(html).to include(">Acme Corp<")
    end
  end

  describe ".coach_avatar_row" do
    it "delegates to avatar_row with first=false by default" do
      expect(described_class).to receive(:avatar_row).with(first: false)
      described_class.coach_avatar_row
    end

    it "delegates to avatar_row with provided first flag" do
      expect(described_class).to receive(:avatar_row).with(first: true)
      described_class.coach_avatar_row(first: true)
    end
  end

  describe ".brand_avatar_row" do
    it "delegates with defaults" do
      expect(described_class).to receive(:avatar_row).with(first: false, name: "replicate.info", photo_path: "logo.png")
      described_class.brand_avatar_row
    end

    it "delegates with custom name and first flag" do
      expect(described_class).to receive(:avatar_row).with(first: true, name: "Acme", photo_path: "logo.png")
      described_class.brand_avatar_row(first: true, name: "Acme")
    end

    it "renders expected HTML with defaults" do
      html = described_class.brand_avatar_row
      expect(html).to include(">replicate.info<")
      expect(html).to include("src='/logo.png'")
    end
  end

  describe ".student_avatar_row" do
    it "uses photo id 1 when engineer_name includes 'Alex'" do
      expect(described_class).to receive(:avatar_row).with(name: "Alex Johnson", photo_path: "profile-photo-1.jpg")
      described_class.student_avatar_row("Alex Johnson")
    end

    it "matches substring variants like 'Alexis'" do
      expect(described_class).to receive(:avatar_row).with(name: "Alexis Rivera", photo_path: "profile-photo-1.jpg")
      described_class.student_avatar_row("Alexis Rivera")
    end

    it "uses photo id 2 when engineer_name includes 'Casey'" do
      expect(described_class).to receive(:avatar_row).with(name: "Casey Lee", photo_path: "profile-photo-2.jpg")
      described_class.student_avatar_row("Casey Lee")
    end

    it "uses photo id 3 for all other names" do
      expect(described_class).to receive(:avatar_row).with(name: "Taylor Morales", photo_path: "profile-photo-3.jpg")
      described_class.student_avatar_row("Taylor Morales")
    end

    it "renders final HTML including name and computed photo path" do
      html = described_class.student_avatar_row("Casey Patel")
      expect(html).to include(">Casey Patel<")
      expect(html).to include("src='/profile-photo-2.jpg'")
    end
  end
end