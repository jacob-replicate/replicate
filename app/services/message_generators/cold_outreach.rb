


module MessageGenerators
  class ColdOutreach < MessageGenerators::Base
    def deliver_intro
      inbox = inboxes.find_by { |inbox| @conversation.context["cold_email_inbox"] == inbox[:email] } || inboxes.sample

      deliver_elements([
        "Hi #{@conversation.recipient.first_name}",
        inbox[:intro].sample,
        inbox[:hook].sample,
        inbox[:ctas].sample,
        inbox[:signature]
      ])
    end

    private
  end
end