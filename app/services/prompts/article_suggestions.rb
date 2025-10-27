module Prompts
  class ArticleSuggestions < Prompts::Base
    def call
      raw_json = JSON.parse(fetch_raw_output) rescue {}
      raw_json = raw_json.with_indifferent_access rescue {}
      options = raw_json["options"].map(&:with_indifferent_access) rescue []

      html = +""
      options.shuffle.each do |option|
        context = {
          conversation_type: :article,
          title: option["title"],
          description: option["description"],
          parent_conversation_id: @conversation.id
        }

        conversation = Conversation.create!(channel: "web", context: context)
        conversation_id = conversation.id

        html << <<~HTML
          <a
            href="/conversations/#{conversation_id}"
            target="_blank"
            rel="noopener noreferrer"
            class="text-[16px] p-3 border block border-gray-300 shadow-sm bg-gray-50 rounded-md hover:border-indigo-400 cursor-pointer transition no-underline"
          >
            <div href="/conversations/#{conversation_id}" target="_blank" class="text-indigo-600 text-[15px] underline underline-offset-4 font-medium">
              #{ERB::Util.html_escape(option["title"])}
            </div>
            <div class="mt-2 text-gray-700 text-[15px]">
              #{ERB::Util.html_escape(option["description"])}
            </div>
          </a>
        HTML
      end

      final_html = <<~HTML
        <div class="mb-4">#{raw_json["intro_sentence"]}</div>
        <div class="flex flex-col gap-4">
          #{html}
        </div>
      HTML

      {
        "html" => final_html,
        "intro_sentence" => raw_json["intro_sentence"]
      }
    end
  end
end