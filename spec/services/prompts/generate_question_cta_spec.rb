require "rails_helper"

RSpec.describe Prompts::GenerateQuestionCta do
  let(:context) do
    {
      experience_name: "Container Isolation",
      experience_description: "Understanding container security boundaries",
      refined_generation_intent: "Explore how kernel vulnerabilities affect container isolation",
      previous_questions: ""
    }
  end

  subject(:prompt) { described_class.new(context: context) }

  describe "#validate" do
    def valid_binary_question
      {
        "question_cta" => {
          "title" => "Can a kernel vulnerability let one container read another container's memory?",
          "subtitle" => "Assume a shared kernel running untrusted workloads.",
          "layout" => "binary",
          "options" => [
            {
              "title" => "Yes",
              "body" => "Kernel bugs like Spectre or Meltdown can bypass isolation. Containers share a kernel, so they inherit its vulnerabilities."
            },
            {
              "title" => "No",
              "body" => "Container isolation through namespaces and cgroups prevents memory access across boundaries."
            }
          ],
          "generation_intent" => "Tests whether they understand that container isolation depends on kernel integrity."
        }
      }
    end

    def valid_multi_option_question
      {
        "question_cta" => {
          "title" => "A leader election keeps failing even though most nodes are healthy. What's the most likely cause?",
          "subtitle" => "Logs show no crashes, just repeated election timeouts.",
          "options" => [
            {
              "title" => "Network partition",
              "body" => "Healthy nodes might be split across network boundaries. Majority exists but can't reach each other."
            },
            {
              "title" => "Clock skew",
              "body" => "Timeouts depend on synchronized clocks. Significant drift could cause nodes to disagree on election timing."
            },
            {
              "title" => "Split vote",
              "body" => "Multiple candidates keep splitting the vote. No one gets a majority because everyone keeps trying at once."
            }
          ],
          "generation_intent" => "Challenges the assumption that nodes healthy equals election should work."
        }
      }
    end

    context "with valid binary question" do
      it "passes validation" do
        failures = prompt.validate(valid_binary_question.to_json)
        expect(failures).to be_empty
      end
    end

    context "with valid multi-option question" do
      it "passes validation" do
        failures = prompt.validate(valid_multi_option_question.to_json)
        expect(failures).to be_empty
      end
    end

    context "with missing question_cta" do
      it "fails validation" do
        failures = prompt.validate({}.to_json)
        expect(failures).to include("missing_question_cta")
      end
    end

    context "with missing title" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"].delete("title")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_missing_title")
      end
    end

    context "with empty title" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"]["title"] = "  "
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_missing_title")
      end
    end

    context "with title not ending in question mark" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"]["title"] = "This is a statement not a question"
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_title_not_a_question")
      end
    end

    context "with missing options" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"].delete("options")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_missing_options")
      end
    end

    context "with invalid option count" do
      it "fails with 1 option" do
        question = valid_binary_question
        question["question_cta"]["options"] = [question["question_cta"]["options"].first]
        question["question_cta"].delete("layout")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_invalid_option_count")
      end

      it "fails with 4 options" do
        question = valid_multi_option_question
        question["question_cta"]["options"] << { "title" => "Fourth", "body" => "Another option" }
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_invalid_option_count")
      end
    end

    context "with binary layout but wrong option count" do
      it "fails with 3 options and binary layout" do
        question = valid_multi_option_question
        question["question_cta"]["layout"] = "binary"
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_binary_wrong_option_count")
      end
    end

    context "with malformed options" do
      it "fails when option is not a hash" do
        question = valid_binary_question
        question["question_cta"]["options"][0] = "not a hash"
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_option_0_not_hash")
      end

      it "fails when option title is missing" do
        question = valid_binary_question
        question["question_cta"]["options"][1].delete("title")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_option_1_missing_title")
      end

      it "fails when option body is missing" do
        question = valid_binary_question
        question["question_cta"]["options"][0].delete("body")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_option_0_missing_body")
      end

      it "fails when option title is empty" do
        question = valid_binary_question
        question["question_cta"]["options"][0]["title"] = ""
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_option_0_missing_title")
      end
    end

    context "with missing generation_intent" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"].delete("generation_intent")
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_missing_generation_intent")
      end
    end

    context "with empty generation_intent" do
      it "fails validation" do
        question = valid_binary_question
        question["question_cta"]["generation_intent"] = "   "
        failures = prompt.validate(question.to_json)
        expect(failures).to include("question_missing_generation_intent")
      end
    end

    context "with markdown-wrapped JSON" do
      it "still passes validation when JSON is wrapped in code blocks" do
        raw_with_markdown = "```json\n#{valid_binary_question.to_json}\n```"
        failures = prompt.validate(raw_with_markdown)
        expect(failures).to be_empty
      end
    end
  end

  describe "#template_name" do
    it "returns the correct template name" do
      expect(prompt.template_name).to eq("generate_question_cta")
    end
  end
end