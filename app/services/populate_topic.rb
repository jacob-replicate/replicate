class PopulateTopic
  def initialize(topic_id)
    @topic = Topic.find(topic_id)
  end

  def call
    generation_intents.each do |generation_intent|
      GenerateExperience.new(@topic.id, generation_intent).call
    rescue StandardError
      nil
    end
  end

  def generation_intents
    existing_experiences = @topic.experiences.templates.pluck(:name, :generation_intent)

    context = {
      topic_name: @topic.name,
      topic_description: @topic.description,
      existing_experiences: existing_experiences.map { |name, intent| "- #{name}: #{intent}" }.join("\n")
    }

    response = Prompts::GenerateTopicExperienceIntents.new(context: context).call
    response["generation_intents"] || []
  end
end