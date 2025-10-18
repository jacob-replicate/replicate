class SanitizeAiContent
  include ActionView::Helpers::SanitizeHelper

  def self.call(response)
    new.clean(response.to_s)
  end

  def clean(response)
    avatars = [
      AvatarService.coach_avatar_row(first: true),
      AvatarService.coach_avatar_row,
      AvatarService.brand_avatar_row(first: true),
      AvatarService.brand_avatar_row,
      AvatarService.brand_avatar_row(name: "Overview"),
      AvatarService.brand_avatar_row(name: "Jacob Comer", first: true, photo_path: "jacob-square.jpg"),
      AvatarService.brand_avatar_row(name: "replicate.info"),
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