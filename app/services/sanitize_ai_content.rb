class SanitizeAiContent
  include ActionView::Helpers::SanitizeHelper

  def self.call(response)
    new.clean(response)  # delegate to instance method
  end

  def clean(response)
    avatars = [
      AvatarService.coach_avatar_row(first: true),
      AvatarService.coach_avatar_row,
      AvatarService.brand_avatar_row(first: true),
      AvatarService.brand_avatar_row,
      AvatarService.brand_avatar_row(name: "Overview"),
      AvatarService.brand_avatar_row(name: "replicate.info"),
      AvatarService.student_avatar_row("Taylor Morales"),
      AvatarService.student_avatar_row("Casey Patel"),
      AvatarService.student_avatar_row("Alex Shaw")
    ]

    avatars.each { |avatar| response.gsub!(avatar, "") }

    response.gsub!("Hey Alex,", "")
    response.gsub!("Hey Taylor,", "")
    response.gsub!("Hey Casey,", "")
    response.gsub!("```html", "")
    response.gsub!("```", "")
    response.gsub!("**", "")
    response.gsub!("`", "")

    strip_tags(response)  # works here because we're in an instance context
  end
end