class SanitizeAiContent
  include ActionView::Helpers::SanitizeHelper

  def self.call(response)
    new.clean(response.to_s)
  end

  def clean(response)
    avatars = [
      AvatarService.coach_avatar_row,
      AvatarService.jacob_avatar_row,
      AvatarService.avatar_row(name: "Incident Summary")
    ].reject(&:blank?)

    avatars.each { |avatar| response.gsub!(avatar, "") }

    response.gsub!("\n", "")
    response.gsub!(HINT_LINK, "")
    response.gsub!(ANOTHER_HINT_LINK, "")
    response.gsub!(FINAL_HINT_LINK, "")
    response.gsub!('<b>', "")
    response.gsub!("</b>", "")
    response.gsub!("<html>", "")
    response.gsub!(/<script\b[^>]*>[\s\S]*?<\/script>/i, "")
    response = strip_tags(response).squish
    response.gsub!("```html", "")
    response.gsub!("```", "")
    response.gsub!(/["""]/, '"')
    response.gsub!("&#39;", "'")
    response.gsub!(/['']/, "'")
    response.gsub!("*", "")
    response.gsub!("`", "")

    response.squish.html_safe
  end
end