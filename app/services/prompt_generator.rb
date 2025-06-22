# Usage: PromptGenerator.new(template_code: "landing_page_incident", user: current_user, input: { incident: "We crashed PostgreSQL" }).call

class PromptGenerator
  def initialize(template_code:, user: nil, input: nil)
    @template = fetch_base_template(template_code)
    @user = user
    @input = input
  end

  def call
    return "" unless @template.present?

    shared_prompts = Dir.glob(Rails.root.join('app', 'prompts', 'shared', '*.txt')).map do |file|
      file_name = File.basename(file, '.txt')
      @template.gsub!("{{#{file_name.upcase}}}", File.read(file))
    end

    Hash(@input).each do |input_key, input_value|
      @template.gsub!("{{INPUT_#{input_key.upcase}}}", input_value)
    end

    @template
  end

  private

  def fetch_base_template(template_code)
    valid_template_names = Dir.glob(Rails.root.join('app', 'prompts', '*.txt')).map { |x| x.split("/").last.gsub(".txt", "") }
    return nil unless valid_template_names.include?(template_code.to_s)
    File.read(Rails.root.join('app', 'prompts', "#{template_code}.txt"))
  end
end