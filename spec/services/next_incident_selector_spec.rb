require "rails_helper"

RSpec.describe NextIncidentSelector do
  let!(:org_1) { create(:organization) }
  let!(:org_2) { create(:organization) }

  let!(:subscribed_1_org_1)   { create(:member, organization: org_1, subscribed: true) }
  let!(:subscribed_2_org_1)   { create(:member, organization: org_1, subscribed: true) }
  let!(:unsubscribed_org_1)   { create(:member, organization: org_1, subscribed: false) }
  let!(:subscribed_1_org_2)   { create(:member, organization: org_2, subscribed: true) }
  let!(:unsubscribed_org_2)   { create(:member, organization: org_2, subscribed: false) }

  let(:incidents) do
    [
      { "prompt" => "Incident A", "code" => "incident-a" },
      { "prompt" => "Incident B", "code" => "incident-b" },
      { "prompt" => "Incident C", "code" => "incident-c" },
    ]
  end

  before do
    stub_const("INCIDENTS", incidents)
  end

  def see(member, prompt)
    create(:conversation, recipient: member, context: { "incident" => prompt })
  end

  describe ".call" do
    context "when the org has no seen incidents among subscribed members" do
      it "return an incident" do
        # Unsubscribed members' conversations should be ignored
        see(unsubscribed_org_1, "Incident A")

        result = described_class.call(org_1)
        expect(INCIDENTS).to include(result)
      end
    end

    context "when some incidents were seen by subscribed members in the org" do
      it "excludes those prompts" do
        see(subscribed_1_org_1, "Incident A")
        see(unsubscribed_org_1, "Incident B")

        result = described_class.call(org_1)

        expect(result).to be_present
        expect(result["prompt"]).not_to eq("Incident A")
        expect(["Incident B", "Incident C"]).to include(result["prompt"])
      end
    end

    context "organization scoping" do
      it "ignores incidents seen by (subscribed) members of other orgs" do
        see(subscribed_1_org_2, "Incident A")
        see(subscribed_1_org_2, "Incident B")

        result = described_class.call(org_1)
        expect(INCIDENTS).to include(result)
      end
    end

    context "blank incident values" do
      it "ignores blank context values when computing seen prompts" do
        create(:conversation, recipient: subscribed_1_org_1, context: { "incident" => "" })
        create(:conversation, recipient: subscribed_2_org_1, context: { "incident" => nil })

        result = described_class.call(org_1)
        expect(INCIDENTS).to include(result)
      end
    end

    context "when all incidents were seen by subscribed members" do
      it "returns nothing" do
        INCIDENTS.each { |inc| see(subscribed_1_org_1, inc["prompt"]) }
        expect(described_class.call(org_1)).to be_blank
      end
    end

    context "when only unsubscribed members have seen all incidents" do
      it "treats everything as unseen (since unsubscribed are ignored)" do
        INCIDENTS.each { |inc| see(unsubscribed_org_1, inc["prompt"]) }

        result = described_class.call(org_1)
        expect(INCIDENTS).to include(result)
      end
    end
  end
end