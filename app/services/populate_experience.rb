class PopulateExperience
  def initialize(experience_id)
    @experience = Experience.find(experience_id)
    @generation_intent = @experience.generation_intent
  end

  def call
    generate_conversation_lists!
    inject_elements!
  ensure
    @experience.update!(state: "populated")
  end

  private

  def generate_conversation_lists!
    context = {
      experience_name: @experience.name,
      experience_description: @experience.description,
      refined_generation_intent: @generation_intent
    }

    response = Prompts::GenerateConversationLists.new(context: context).call

    Array(response["categories"]).each_with_index do |category, i|
      puts "Creating list #{i}: #{category["name"]}"
      list_element = Element.create!(
        experience: @experience,
        code: "conversation_list",
        sort_order: i,
        context: { "name" => category["name"] }
      )

      category["questions"].each_with_index do |question, idx|
        Element.create!(
          experience: @experience,
          element: list_element,
          code: "conversation_list_row",
          context: { "name" => question, "cta" => "Start" }
        )
      end
    end
  end

  def inject_elements!
    elements = @experience.elements.root_level.order(sort_order: :asc).to_a
    list_count = elements.length - 1
    return if elements.length < 2

    previous_incidents = []
    previous_design_reviews = []
    previous_questions = []
    recently_used_element_types = []
    lists_counted = 0
    gap_threshold = rand(1..2)
    i = 0

    while i < list_count
      lists_counted += 1

      if lists_counted >= gap_threshold
        # Reset once all 3 types have been used
        if recently_used_element_types.length >= 3
          recently_used_element_types = []
        end

        # Pick a type we haven't used recently
        available_types = [:incident, :design_review, :question_cta] - recently_used_element_types
        element_type = available_types.sample
        recently_used_element_types << element_type

        insert_sort_order = elements[i + 1].sort_order
        elements.each do |el|
          if el.sort_order >= insert_sort_order
            puts "Updating #{el.inspect}"
            el.update!(sort_order: el.sort_order + 1)
          end
        end

        case element_type
        when :incident
          new_el = generate_single_incident!(previous_incidents)
          new_el.update!(sort_order: insert_sort_order)
          previous_incidents << new_el.generation_intent if new_el.generation_intent.present?
        when :design_review
          new_el = generate_single_design_review!(previous_design_reviews)
          new_el.update!(sort_order: insert_sort_order)
          previous_design_reviews << new_el.generation_intent if new_el.generation_intent.present?
        when :question_cta
          new_el = generate_single_question_cta!(previous_questions)
          new_el.update!(sort_order: insert_sort_order)
          previous_questions << new_el.generation_intent if new_el.generation_intent.present?
        end

        lists_counted = 0
        gap_threshold = rand(1..2)
      end

      i += 1
    end
  end

  def generate_single_incident!(previous_incidents)
    context = {
      experience_name: @experience.name,
      experience_description: @experience.description,
      refined_generation_intent: @generation_intent,
      previous_incidents: previous_incidents.join("; ")
    }

    response = Prompts::GenerateIncident.new(context: context).call
    incident = response["incident"]

    Element.create!(
      experience: @experience,
      code: "incident_cta",
      sort_order: 0,
      generation_intent: incident["generation_intent"],
      context: {
        "title" => incident["title"],
        "body" => incident["body"],
        "signals" => incident["signals"]
      }
    )
  end

  def generate_single_design_review!(previous_design_reviews)
    context = {
      experience_name: @experience.name,
      experience_description: @experience.description,
      refined_generation_intent: @generation_intent,
      previous_design_reviews: previous_design_reviews.join("; ")
    }

    response = Prompts::GenerateDesignReview.new(context: context).call
    review = response["design_review"]

    Element.create!(
      experience: @experience,
      code: "design_review_cta",
      sort_order: 0,
      generation_intent: review["generation_intent"],
      context: {
        "title" => review["title"],
        "subtitle" => review["subtitle"],
        "body" => review["body"],
        "input_placeholder" => review["input_placeholder"]
      }
    )
  end

  def generate_single_question_cta!(previous_questions)
    context = {
      experience_name: @experience.name,
      experience_description: @experience.description,
      refined_generation_intent: @generation_intent,
      previous_questions: previous_questions.join("; ")
    }

    response = Prompts::GenerateQuestionCta.new(context: context).call
    question = response["question_cta"]

    element_context = {
      "title" => question["title"],
      "subtitle" => question["subtitle"]
    }

    # Add layout field only for binary questions (2 options)
    element_context["layout"] = "binary" if question["layout"] == "binary"

    question_element = Element.create!(
      experience: @experience,
      code: "question_cta",
      sort_order: 0,
      generation_intent: question["generation_intent"],
      context: element_context
    )

    # Create child elements for each option, inheriting the question's generation_intent
    question["options"].each_with_index do |opt, idx|
      Element.create!(
        experience: @experience,
        element: question_element,
        code: "question_cta_option",
        sort_order: idx,
        context: {
          "title" => opt["title"],
          "body" => opt["body"]
        }
      )
    end

    question_element
  end
end