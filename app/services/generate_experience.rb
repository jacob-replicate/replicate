class GenerateExperience
  def initialize(topic_id, generation_intent)
    @topic = Topic.find_by(id: topic_id)
    @generation_intent = generation_intent
  end

  def call
    generate_experience_container!
  end

  def generate_experience_container!
    context = {
      topic_name: @topic&.name,
      topic_description: @topic&.description,
      experience_generation_intent: @generation_intent
    }

    response = Prompts::GenerateExperienceBasics.new(context: context).call

    Experience.create!(
      topic: @topic,
      code: response["experience_code"],
      name: response["experience_name"],
      description: response["experience_description"],
      generation_intent: response["refined_generation_intent"],
      template: true,
      state: "pending"
    )
  end
end