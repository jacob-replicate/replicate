class PostmarkWebhook < ApplicationRecord
  belongs_to :conversation, optional: true

  def message
    content["StrippedTextReply"]
  end

  def postmark_message_id
    content["MessageID"]
  end

  def in_reply_to_message
    relevant_ids = content["Headers"].find { |x| x["Name"] == "In-Reply-To" }["Value"] rescue nil

    if relevant_ids.blank?
      relevant_ids = content["Headers"].find { |x| x["Name"] == "References" }["Value"].split(" ") rescue nil
    end

    return nil unless relevant_ids.present?

    Message.where(email_message_id_header: relevant_ids).first
  end

  def rfc_message_id
    hdr = Array(content["Headers"]).find { |h| h["Name"].to_s.downcase == "message-id" || h["Name"].to_s.downcase == "message-id:" }
    hdr&.dig("Value")
  end
end