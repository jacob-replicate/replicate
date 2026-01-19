require 'rails_helper'

RSpec.describe Experience, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:topic).optional }
    it { is_expected.to have_many(:elements).dependent(:destroy) }
  end

  describe ".templates" do
    let!(:template) { create(:experience, template: true) }
    let!(:non_template) { create(:experience, template: false) }

    it "returns only template experiences" do
      expect(Experience.templates).to include(template)
      expect(Experience.templates).not_to include(non_template)
    end
  end

  describe "#fork!" do
    let(:template) { create(:experience, code: "test_code", name: "Test", description: "Desc", template: true) }
    let!(:root_element) { create(:element, experience: template, element: nil) }
    let!(:child_element) { create(:element, experience: template, element: root_element) }
    let(:session_id) { "new_session_123" }

    it "creates a new non-template experience" do
      forked = template.fork!(session_id)

      expect(forked.template).to be false
      expect(forked.session_id).to eq(session_id)
    end

    it "copies experience attributes" do
      forked = template.fork!(session_id)

      expect(forked.code).to eq(template.code)
      expect(forked.name).to eq(template.name)
      expect(forked.description).to eq(template.description)
    end

    it "forks all root-level elements" do
      forked = template.fork!(session_id)

      expect(forked.elements.count).to eq(2)
    end

    it "reuses existing forked experience for same session" do
      first_fork = template.fork!(session_id)
      second_fork = template.fork!(session_id)

      expect(first_fork.id).to eq(second_fork.id)
    end

    it "does not re-fork elements if experience already exists with elements" do
      first_fork = template.fork!(session_id)
      initial_element_count = first_fork.elements.count

      template.fork!(session_id)

      expect(first_fork.reload.elements.count).to eq(initial_element_count)
    end
  end
end