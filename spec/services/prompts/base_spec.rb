require "rails_helper"

RSpec.describe Prompts::Base do
  let(:prompt_context) { {} }
  let(:conversation) { build(:conversation, context: { greeting: "Howdy", name: "Jacob" }) }
  subject(:prompt) { described_class.new(conversation: conversation, context: prompt_context) }

  describe "#initialize" do
    context "when explicit context is provided" do
      let(:prompt_context) { { name: "Overridden" } }

      it "prefers the explicit context over conversation.context" do
        expect(prompt.instance_variable_get(:@context)).to eq({ name: "Overridden" })
      end
    end

    context "when explicit context is blank but conversation present" do
      let(:prompt_context) { {} }

      it "falls back to conversation.context" do
        expect(prompt.instance_variable_get(:@context)).to eq(conversation.context)
      end
    end

    context "when both conversation and context are blank" do
      let(:conversation) { nil }
      let(:prompt_context) { {} }

      it "initializes with an empty hash" do
        expect(described_class.new(conversation: nil, context: {}).instance_variable_get(:@context)).to eq({})
      end
    end
  end

  describe "#call" do
    it "delegates to #fetch_valid_response" do
      allow(prompt).to receive(:fetch_valid_response).and_return("final")
      expect(prompt.call).to eq("final")
    end
  end

  describe "#fetch_valid_response" do
    context "when the first attempt validates" do
      it "returns the sanitized output" do
        allow(prompt).to receive(:fetch_raw_output).and_return("raw")
        allow(SanitizeAiContent).to receive(:call).with("raw").and_return("sanitized")
        allow(prompt).to receive(:validate).with("sanitized").and_return(nil)

        expect(prompt.fetch_valid_response).to eq("sanitized")
      end
    end

    context "when validation fails repeatedly" do
      it "logs the error each time and returns nil after 10 tries" do
        described_class.class_variable_set(:@@template_cache, {})

        allow(prompt).to receive(:fetch_raw_output).and_return("raw")
        allow(SanitizeAiContent).to receive(:call).and_return("still-bad")
        allow(prompt).to receive(:validate).and_return("nope")
        allow(Rails.logger).to receive(:error)

        expect(prompt.fetch_valid_response).to be_nil
        expect(Rails.logger).to have_received(:error).exactly(10).times
      end
    end
  end

  describe "#fetch_raw_output" do
    it "raises in test env to prevent hitting the network" do
      expect { prompt.send(:fetch_raw_output) }.to raise_error(StandardError)
    end
  end

  describe "#template_name" do
    it "demodulizes and underscores the class name" do
      expect(prompt.send(:template_name)).to eq("base")
    end
  end

  describe "#template" do
    context "when file does not exist" do
      it "returns nil" do
        described_class.class_variable_set(:@@template_cache, {})
        allow(File).to receive(:exist?).and_return(false)

        expect(prompt.send(:template, name: "anything")).to be_nil
      end
    end

    context "when file exists and not production" do
      it "reads every time and does not return early from cache" do
        described_class.class_variable_set(:@@template_cache, {})
        allow(Rails).to receive_message_chain(:env, :production?).and_return(false)

        # first call returns "v1", second call returns "v2"
        allow(File).to receive(:exist?).and_return(true)
        call_count = 0
        allow(File).to receive(:read) do
          call_count += 1
          call_count == 1 ? "v1" : "v2"
        end

        first  = prompt.send(:template, name: "base")
        second = prompt.send(:template, name: "base")

        expect(first).to eq("v1")
        expect(second).to eq("v2")
      end
    end

    context "when file exists and production" do
      it "returns cached value without re-reading" do
        described_class.class_variable_set(:@@template_cache, {})
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)

        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return("cached-value")

        first  = prompt.send(:template, name: "base")
        allow(File).to receive(:read).and_return("different") # should not be used
        second = prompt.send(:template, name: "base")

        expect(first).to eq("cached-value")
        expect(second).to eq("cached-value")
      end
    end

    context "with shared: true" do
      it "uses an independent cache key from non-shared" do
        described_class.class_variable_set(:@@template_cache, {})
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
        allow(File).to receive(:exist?).and_return(true)

        allow(File).to receive(:read).and_return("normal")
        normal = prompt.send(:template, name: "header")

        allow(File).to receive(:read).and_return("shared")
        shared = prompt.send(:template, name: "header", shared: true)

        expect(normal).to eq("normal")
        expect(shared).to eq("shared")
      end
    end
  end

  describe "#instructions" do
    context "when base template is missing" do
      it "returns an empty string" do
        allow(prompt).to receive(:template).and_return(nil)
        expect(prompt.send(:instructions)).to eq("")
      end
    end

    context "when base template exists with shared placeholders and context tokens" do
      let(:prompt_context) { { name: "Jacob", greeting: "Hey" } }

      it "expands shared partials and interpolates context" do
        base_text   = "Start: {{HEADER}} | {{CONTEXT_GREETING}}, {{CONTEXT_NAME}}!"
        header_text = "TopSection"

        # The first call (no args passed) is the base template; subsequent shared templates by name.
        allow(prompt).to receive(:template) do |args = {}|
          if args.nil? || args == {} || args[:name].nil?
            base_text
          elsif args[:shared]
            case args[:name]
              when "header" then header_text
              else "SHARED-#{args[:name].upcase}"
            end
          else
            "IGNORED"
          end
        end

        allow(Dir).to receive(:glob).and_return(
          [Rails.root.join("app", "prompts", "shared", "header.txt").to_s]
        )

        expect(prompt.send(:instructions)).to eq("Start: TopSection | Hey, Jacob!")
      end
    end

    context "when the cached template string is frozen" do
      it "duplicates before mutation and does not raise" do
        frozen_text = "Hi {{CONTEXT_NAME}}".freeze
        allow(prompt).to receive(:template).and_return(frozen_text)
        allow(Dir).to receive(:glob).and_return([])

        expect { prompt.send(:instructions) }.not_to raise_error
        expect(prompt.send(:instructions)).to eq("Hi Jacob")
      end
    end
  end
end