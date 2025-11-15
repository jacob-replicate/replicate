module Prompts
  class CoachingIntro < Prompts::Base
    def call
      parallel_batch_process do |elements|
        first_element = elements.first.to_s

        elements.is_a?(Array) &&
          elements.size == 2 &&
          elements.all? { |element| Hash(element)["type"].present? } &&
          elements.map { |e| e["type"] } == ["paragraph", "code"] &&
          elements.first["content"].to_s.length < 300
      end
    end
  end
end