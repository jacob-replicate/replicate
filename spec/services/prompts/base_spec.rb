require "rails_helper"

RSpec.describe Prompts::Base do
  let(:prompt_context) { { name: "Jacob", greeting: "Hey" } }
  let(:message_history) { [] }
  subject(:prompt) { described_class.new(context: prompt_context, message_history: message_history) }

  describe "#initialize" do
    it "stores context with indifferent access and adds current_time" do
      ctx = prompt.instance_variable_get(:@context)
      expect(ctx["name"]).to eq("Jacob")
      expect(ctx[:name]).to eq("Jacob")
      expect(ctx).to have_key(:current_time)
    end

    it "stores message_history" do
      history = [{ role: "user", content: "Hello" }]
      p = described_class.new(context: {}, message_history: history)
      expect(p.instance_variable_get(:@message_history)).to eq(history)
    end

    context "when context is empty" do
      let(:prompt_context) { {} }

      it "initializes with current_time only" do
        ctx = prompt.instance_variable_get(:@context)
        expect(ctx).to have_key(:current_time)
        expect(ctx.keys).to eq(["current_time"])
      end
    end
  end

  describe "#call" do
    it "delegates to #run_batch_process" do
      allow(prompt).to receive(:run_batch_process).and_return("final")
      expect(prompt.call).to eq("final")
    end
  end

  describe "#run_batch_process" do
    it "returns empty array in test environment" do
      expect(prompt.run_batch_process).to eq([])
    end
  end

  describe "#fetch_llm_response" do
    it "raises in test env to prevent hitting the network" do
      expect { prompt.send(:fetch_llm_response) }.to raise_error(StandardError)
    end
  end

  describe "#template_name" do
    it "demodulizes and underscores the class name" do
      expect(prompt.send(:template_name)).to eq("base")
    end
  end

  describe "#template" do
    before do
      described_class.class_variable_set(:@@template_cache, {})
    end

    context "when file does not exist" do
      it "returns nil" do
        allow(File).to receive(:exist?).and_return(false)

        expect(prompt.send(:template, name: "anything")).to be_nil
      end
    end

    context "when file exists and not production" do
      it "reads every time and does not return early from cache" do
        allow(Rails.env).to receive(:production?).and_return(false)

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
        allow(Rails.env).to receive(:production?).and_return(true)

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
        allow(Rails.env).to receive(:production?).and_return(true)
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
      it "expands shared partials and interpolates context" do
        base_text   = "Start: {{HEADER}} | {{CONTEXT_GREETING}}, {{CONTEXT_NAME}}!"
        header_text = "TopSection"

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

  describe ".extract_json" do
    it "extracts JSON from code fence" do
      raw = '```json\n{"key": "value"}\n```'
      result = described_class.extract_json(raw)
      expect(result["key"]).to eq("value")
    end

    it "extracts JSON without code fence" do
      raw = '{"key": "value"}'
      result = described_class.extract_json(raw)
      expect(result["key"]).to eq("value")
    end

    it "returns empty hash on invalid JSON" do
      raw = "not json"
      result = described_class.extract_json(raw)
      expect(result).to eq({})
    end
  end
end