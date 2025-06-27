class CreatePromptChunks < ActiveRecord::Migration[7.1]
  def change
    enable_extension "vector"

    create_table :prompt_chunks do |t|
      t.text :content, null: false
      t.timestamps
    end

    execute <<~SQL
      ALTER TABLE prompt_chunks
      ADD COLUMN embedding vector(3072);
    SQL
  end
end