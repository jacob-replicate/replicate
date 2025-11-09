module Prompts
  class CoachingIntro < Prompts::Base
    def call
      parallel_batch_process do |elements|
        first_element = elements.first.to_s

        elements.is_a?(Array) &&
          elements.size == 3 &&
          elements.all? { |element| Hash(element)["type"].present? } &&
          elements.map { |e| e["type"] } == ["paragraph", "code", "paragraph"]
      end
    end

    def suffix
      "<p class='cta-subheader' style='margin-top: 30px; font-size: 17px'><span class='font-semibold'>What's your first move here?</span></p>"
    end
  end
end