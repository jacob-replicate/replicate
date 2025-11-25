class RenameLlmTemplateName < ActiveRecord::Migration[7.1]
  def change
    rename_column :cached_llm_responses, :llm_template_name, :template_name
  end
end