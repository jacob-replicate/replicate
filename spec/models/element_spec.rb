require 'rails_helper'

RSpec.describe Element, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:experience) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:conversation).optional }
    it { is_expected.to belong_to(:element).optional }
    it { is_expected.to belong_to(:experience) }
    it { is_expected.to have_many(:elements).dependent(:destroy) }
  end

  describe ".root_level" do
    let(:experience) { create(:experience) }
    let!(:root_element) { create(:element, experience: experience, element: nil) }
    let!(:child_element) { create(:element, experience: experience, element: root_element) }

    it "returns only elements without a parent" do
      expect(Element.root_level).to include(root_element)
      expect(Element.root_level).not_to include(child_element)
    end
  end

  describe "#fork!" do
    let(:original_experience) { create(:experience, template: true) }
    let(:new_experience) { create(:experience, template: false) }
    let!(:root_element) { create(:element, code: "root", context: "root_context", experience: original_experience, sort_order: 1) }
    let!(:child_element) { create(:element, code: "child", context: "child_context", experience: original_experience, element: root_element, sort_order: 2) }

    it "creates a copy of the element for the new experience" do
      expect { root_element.fork!(new_experience) }.to change { Element.count }.by(2)
    end

    it "copies element attributes" do
      root_element.fork!(new_experience)
      forked = new_experience.elements.root_level.first

      expect(forked.code).to eq("root")
      expect(forked.context).to eq("root_context")
      expect(forked.sort_order).to eq(1)
    end

    it "recursively forks child elements" do
      root_element.fork!(new_experience)
      forked_root = new_experience.elements.root_level.first
      forked_child = forked_root.elements.first

      expect(forked_child.code).to eq("child")
      expect(forked_child.context).to eq("child_context")
    end

    it "clears conversation association on forked elements" do
      root_element.update!(conversation: create(:conversation))
      root_element.fork!(new_experience)
      forked = new_experience.elements.root_level.first

      expect(forked.conversation).to be_nil
    end
  end

  describe "#create_conversation!" do
    let(:experience) { create(:experience) }

    context "with incident_cta code" do
      let(:element) { create(:element, code: "incident_cta", experience: experience) }

      it "creates an incident conversation" do
        expect { element.create_conversation! }.to change { Conversation.count }.by(1)
        expect(element.reload.conversation.variant).to eq("incident")
      end
    end

    context "with unsupported code" do
      let(:element) { create(:element, code: "unknown_code", experience: experience) }

      it "raises ArgumentError" do
        expect { element.create_conversation! }.to raise_error(ArgumentError, /Unknown element code/)
      end
    end

    context "with conversation_list_row code" do
      let(:element) { create(:element, code: "conversation_list_row", experience: experience, context: { "name" => "Test question topic" }) }

      it "creates a question conversation" do
        expect { element.create_conversation! }.to change { Conversation.count }.by(1)
        expect(element.reload.conversation.variant).to eq("question")
        expect(element.conversation.generation_intent).to eq("Test question topic")
      end
    end

    context "with unimplemented codes" do
      %w[design_review_cta question_cta question_cta_option].each do |code|
        it "raises NotImplementedError for #{code}" do
          element = create(:element, code: code, experience: experience)
          expect { element.create_conversation! }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end