require 'rails_helper'

RSpec.describe ScheduleWeeklyCoachingEmailsWorker, type: :worker do
  let(:start_time) { Time.current }
  let(:current_day_start) { Time.current.beginning_of_day.to_i }

  let!(:active_org_1) { create(:organization, access_end_date: 1.month.from_now) }
  let!(:active_org_2) { create(:organization, access_end_date: 2.months.from_now) }
  let!(:inactive_org) { create(:organization, access_end_date: 1.month.ago) }

  let!(:active_member_1_active_org_1) { create(:member, organization: active_org_1, subscribed: true) }
  let!(:active_member_1_active_org_2) { create(:member, organization: active_org_2, subscribed: true) }
  let!(:active_member_inactive_org) { create(:member, organization: inactive_org, subscribed: true) }

  let!(:inactive_member_active_org_1) { create(:member, organization: active_org_1, subscribed: false) }
  let!(:inactive_member_active_org_2) { create(:member, organization: active_org_2, subscribed: false) }
  let!(:inactive_member_inactive_org) { create(:member, organization: inactive_org, subscribed: false) }

  let(:email_incidents) do
    [
      { prompt: 'Incident A', code: 'incident-a' },
      { prompt: 'Incident B', code: 'incident-b' },
    ]
  end

  before do
    stub_const("EMAIL_INCIDENTS", email_incidents)
    allow_any_instance_of(ScheduleWeeklyCoachingEmailsWorker).to receive(:delay_second_increment).and_return(1)
  end

  describe '#perform' do
    context 'when no organization_ids are passed' do
      it 'schedules emails for all subscribed members across active orgs' do
        Timecop.freeze do
          allow_any_instance_of(ScheduleWeeklyCoachingEmailsWorker).to receive(:fetch_next_incident).and_return(email_incidents.first)
          expect(StartWeeklyCoachingEmailWorker).to receive(:perform_at).with((Time.at(start_time) + 1.second).change(usec: 0), active_member_1_active_org_1.id, email_incidents.first)
          expect(StartWeeklyCoachingEmailWorker).to receive(:perform_at).with((Time.at(start_time) + 2.second).change(usec: 0), active_member_1_active_org_2.id, email_incidents.first)
          expect(StartWeeklyCoachingEmailWorker).not_to receive(:perform_at).with(anything, active_member_inactive_org.id, email_incidents.first)
          described_class.new.perform(nil, start_time.to_i, current_day_start)
        end
      end
    end

    context 'when specific organization_ids are passed' do
      it 'only schedules emails for members in those orgs' do
      end
    end

    it "fetches a fresh random incident for each organization every week" do
    end

    context 'when all incidents have been seen' do
      it "returns early without scheduling anything" do
      end
    end
  end
end