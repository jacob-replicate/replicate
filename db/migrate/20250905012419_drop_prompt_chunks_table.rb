class DropPromptChunksTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :prompt_chunks
  end
end