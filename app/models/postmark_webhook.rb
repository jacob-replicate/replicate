class PostmarkWebhook < ApplicationRecord
  belongs_to :conversation, optional: true

  def message
    content["TextBody"]
  end

  def postmark_message_id
    content["MessageID"]
  end

  def rfc_message_id
    hdr = Array(content["Headers"]).find { |h| h["Name"].to_s.downcase == "message-id" || h["Name"].to_s.downcase == "message-id:" }
    hdr&.dig("Value")
  end
end