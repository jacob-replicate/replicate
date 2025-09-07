require "rails_helper"

RSpec.describe ScheduleContactFetchingWorker do
  subject(:worker) { described_class.new }
  let(:job_title) { "vp of engineering" }

  describe "#perform" do
    context "when pagination reports multiple pages" do
      it "fetches pagination and schedules each page with 20s staggering" do
        allow_any_instance_of(FetchContactsWorker).to receive(:perform).with(job_title, 1, true).and_return({ "total_pages" => 3 })
        expect(FetchContactsWorker).to receive(:perform_in).with(20.seconds, job_title, 1).once
        expect(FetchContactsWorker).to receive(:perform_in).with(40.seconds, job_title, 2).once
        expect(FetchContactsWorker).to receive(:perform_in).with(60.seconds, job_title, 3).once
        worker.perform(job_title)
      end
    end

    context "when there are zero pages" do
      it "schedules nothing" do
        allow_any_instance_of(FetchContactsWorker).to receive(:perform).with(job_title, 1, true).and_return({ "total_pages" => 0 })
        expect(FetchContactsWorker).not_to receive(:perform_in)
        worker.perform(job_title)
      end
    end

    context "when pagination is missing total_pages" do
      it "schedules nothing" do
        allow_any_instance_of(FetchContactsWorker).to receive(:perform).with(job_title, 1, true).and_return(nil)
        expect(FetchContactsWorker).not_to receive(:perform_in)
        worker.perform(job_title)
      end
    end
  end
end