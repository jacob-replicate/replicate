class PostmarkWebhook < ApplicationRecord
  belongs_to :conversation, optional: true

  def message
    content["TextBody"]
  end

  def message_id
    content["MessageID"]
  end
end