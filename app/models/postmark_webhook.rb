class PostmarkWebhook < ApplicationRecord
  belongs_to :conversation, optional: true

  def message
    content["TextBody"]
  end
end