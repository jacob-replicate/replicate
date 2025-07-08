class GenerateColdEmailSequenceWorker
  include Sidekiq::Worker

  def perform(email_address)
    contact = Contact.find_by(email: email_address)
    # return if contact.blank?

    cold_email = JSON.parse(Prompt.new(:cold_email_initial).execute)

    puts "Subject: #{cold_email['subject']}"
    puts "Body: #{cold_email['body']}"
  end

  private

  def generate_email(prompt, input)
    content = JSON.parse(Prompt.new(prompt, input: input).execute)

    content["subject"] = sanitize(content["subject"])
    content["body"] = sanitize(content["body"])

    content
  end

  def sanitize(text)
    ActionController::Base.helpers.strip_tags(text).gsub("Replicate.info", "replicate.info").gsub("Replicate", "replicate.info")
  end
end