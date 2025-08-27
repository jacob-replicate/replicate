class AvatarService
  def self.coach_avatar_row(first: false)
    avatar_row(first: first)
  end

  def self.brand_avatar_row(first: false, name: "replicate.info")
    avatar_row(first: first, name: name, photo_path: "logo.png")
  end

  def self.student_avatar_row(engineer_name)
    photo_id = if engineer_name.include?("Alex")
      1
    elsif engineer_name.include?("Casey")
      2
    else
      3
    end

    avatar_row(name: engineer_name, photo_path: "profile-photo-#{photo_id}.jpg")
  end

  def self.avatar_row(name: "replicate.info", photo_path: "logo.png", first: false)
    "<div><div class='flex items-center gap-3'><div style='width: 32px'><img src='/#{photo_path}' class='rounded-full' /></div><div class='font-medium'>#{name}</div></div></div>"
  end
end