class CreateCachedLlmResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :cached_llm_responses, id: :uuid do |t|
      t.text :llm_template_name
      t.jsonb :inputs
      t.text :input_hash
      t.jsonb :response

      t.timestamps
    end

    add_index :cached_llm_responses, [:llm_template_name, :input_hash], name: 'index_cached_llm_on_template_and_input_hash'
  end
end