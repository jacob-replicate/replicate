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

    bold_start_placeholder = "___BOLD_START___"
    bold_end_placeholder = "___BOLD_END___"
    bold_start_replacement = "<b class='font-medium'>"

    response.gsub!("\n", "")
    response.gsub!(HINT_LINK, "")
    response.gsub!(ANOTHER_HINT_LINK, "")
    response.gsub!(FINAL_HINT_LINK, "")
    response.gsub!('<b>', "")
    response.gsub!("</b>", "")
    response.gsub!("<html>", "")
    response.gsub!(/<script\b[^>]*>[\s\S]*?<\/script>/i, "")
    response = strip_tags(response).squish
    response.gsub!("Hey Alex,", "")
    response.gsub!("Hey Taylor,", "")
    response.gsub!("Hey Casey,", "")
    response.gsub!("```html", "")
    response.gsub!("```", "")
    response.gsub!("“", "\"")
    response.gsub!("”", "\"")
    response.gsub!("&#39;", "'")
    response.gsub!("’", "'")
    response.gsub!("*", "")
    response.gsub!("`", "")
    response.gsub!(bold_start_placeholder, "<b class='font-medium'>")
    response.gsub!(bold_end_placeholder, "</b>")

    response.squish.html_safe
  end
end