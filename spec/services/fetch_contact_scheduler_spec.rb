require "rails_helper"

RSpec.describe FetchContactScheduler do
  describe ".call" do
    before do
      allow(ScheduleContactFetchingWorker).to receive(:perform_in)
    end

    it "schedules each keyword with 2-minute staggering and downcases them" do
      keywords = ["SRE", "sre", "Platform", "platform", "Security"]

      described_class.call(keywords)

      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(0.minutes,  "sre").once
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(2.minutes,  "platform").once
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(4.minutes,  "security").once
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).exactly(3).times
    end

    it "defaults to leadership keywords when given no specific keywords" do
      described_class.call
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(0.minutes,  "cto").once
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(2.minutes,  "director of cloud").once
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).with(4.minutes,  "director of devops").once
      # etc.
      expect(ScheduleContactFetchingWorker).to have_received(:perform_in).exactly(20).times
    end
  end
end