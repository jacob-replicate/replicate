require 'rails_helper'

RSpec.describe ScheduleWeeklyCoachingEmailsWorker, type: :worker do
  let(:start_time) { Time.current }
  let(:current_day_start) { Time.current.beginning_of_day.to_i }

  let!(:active_org_1) { create(:organization, access_end_date: 1.month.from_now) }
  let!(:active_org_2) { create(:organization, access_end_date: 2.months.from_now) }
  let!(:inactive_org) { create(:organization, access_end_date: 1.month.ago) }

  let!(:active_member_active_org_1) { create(:member, organization: active_org_1, subscribed: true) }
  let!(:active_member_active_org_2) { create(:member, organization: active_org_2, subscribed: true) }
  let!(:active_member_inactive_org) { create(:member, organization: inactive_org, subscribed: true) }

  let!(:inactive_member_active_org_1) { create(:member, organization: active_org_1, subscribed: false) }
  let!(:inactive_member_active_org_2) { create(:member, organization: active_org_2, subscribed: false) }
  let!(:inactive_member_inactive_org) { create(:member, organization: inactive_org, subscribed: false) }

  before do
    allow_any_instance_of(ScheduleWeeklyCoachingEmailsWorker).to receive(:delay_second_increment).and_return(1)
  end

  context 'when no organization_ids are passed' do
    it 'schedules emails for all subscribed members across active orgs' do
      allow(NextIncidentSelector).to receive(:call).and_return(EMAIL_INCIDENTS.first)

      Timecop.freeze do
        expect(CreateIncidentWorker).to receive(:perform_at).with((Time.at(start_time) + 1.second).change(usec: 0), active_member_active_org_1.id, EMAIL_INCIDENTS.first)
        expect(CreateIncidentWorker).to receive(:perform_at).with((Time.at(start_time) + 2.second).change(usec: 0), active_member_active_org_2.id, EMAIL_INCIDENTS.first)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, active_member_inactive_org.id, EMAIL_INCIDENTS.first)
        described_class.new.perform(nil, start_time.to_i, current_day_start)
      end
    end
  end

  context 'when specific organization_ids are passed' do
    it 'only schedules emails for members in those orgs' do
      allow(NextIncidentSelector).to receive(:call).and_return(EMAIL_INCIDENTS.first)

      Timecop.freeze do
        expect(CreateIncidentWorker).to receive(:perform_at).with((Time.at(start_time) + 1.second).change(usec: 0), active_member_active_org_1.id, EMAIL_INCIDENTS.first)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, active_member_active_org_2.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_active_org_1.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_active_org_2.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, active_member_inactive_org.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_inactive_org.id, anything)
        described_class.new.perform([active_org_1.id], start_time.to_i, current_day_start)
      end
    end
  end

  it "defaults start_time to noon of current_day_start when start_time is nil" do
    allow(NextIncidentSelector).to receive(:call).and_return(EMAIL_INCIDENTS.first)

    Timecop.freeze do
      expected_base = Time.at(current_day_start).advance(hours: 12).change(usec: 0)

      expect(CreateIncidentWorker).to receive(:perform_at).with(expected_base + 1.second, active_member_active_org_1.id, EMAIL_INCIDENTS.first)
      expect(CreateIncidentWorker).to receive(:perform_at).with(expected_base + 2.second, active_member_active_org_2.id, EMAIL_INCIDENTS.first)

      described_class.new.perform(nil, nil, current_day_start)
    end
  end

  context 'when all incidents have been seen' do
    it "returns early without scheduling anything" do
      Timecop.freeze do
        allow(NextIncidentSelector).to receive(:call).with(active_org_1).and_return(nil)
        allow(NextIncidentSelector).to receive(:call).with(active_org_2).and_return(EMAIL_INCIDENTS.first)

        expect(CreateIncidentWorker).to receive(:perform_at).with((Time.at(start_time) + 1.second).change(usec: 0), active_member_active_org_2.id, EMAIL_INCIDENTS.first)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, active_member_active_org_1.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_active_org_1.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_active_org_2.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, active_member_inactive_org.id, anything)
        expect(CreateIncidentWorker).not_to receive(:perform_at).with(anything, inactive_member_inactive_org.id, anything)

        described_class.new.perform(nil, start_time.to_i, current_day_start)
      end
    end
  end

  it "does nothing when no active organizations are targeted" do
    expect(NextIncidentSelector).not_to receive(:call)
    expect(CreateIncidentWorker).not_to receive(:perform_at)

    Timecop.freeze do
      described_class.new.perform([inactive_org.id], start_time.to_i, current_day_start)
    end
  end

  it "always zeroes microseconds on perform_at times" do
    times = []
    allow(NextIncidentSelector).to receive(:call).and_return(EMAIL_INCIDENTS.first)
    allow(CreateIncidentWorker).to receive(:perform_at) { |t, *_| times << t }
    Timecop.freeze { described_class.new.perform(nil, start_time.to_i, current_day_start) }
    expect(times).to all(satisfy { |t| t.usec.zero? })
  end

  it "calls NextIncidentSelector once per active organization" do
    expect(NextIncidentSelector).to receive(:call).with(active_org_1).and_return(EMAIL_INCIDENTS.first.to_h)
    expect(NextIncidentSelector).to receive(:call).with(active_org_2).and_return(EMAIL_INCIDENTS.first.to_h)
    expect(NextIncidentSelector).not_to receive(:call).with(inactive_org)
    expect(CreateIncidentWorker).to receive(:perform_at).twice

    Timecop.freeze do
      described_class.new.perform(nil, start_time.to_i, current_day_start)
    end
  end
end