module Prompts
  class ArticleSuggestions < Prompts::Base
    def call
      raw_json = JSON.parse(fetch_raw_output) rescue {}
      raw_json = raw_json.with_indifferent_access
      options = raw_json["options"].map(&:with_indifferent_access)

      options.each do |option|
        context = {
          conversation_type: :article,
          title: option["title"],
          description: option["description"],
          parent_conversation_id: @conversation.id
        }

        conversation = Conversation.create!(channel: "web", context: context)
        option["conversation_id"] = conversation.id
      end

      {
        "options" => options.shuffle,
        "intro_sentence" => raw_json["intro_sentence"]
      }
    end
  end
end