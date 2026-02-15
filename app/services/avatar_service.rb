class AvatarService
  def self.jacob_avatar_row
    avatar_row(name: "Jacob Comer", photo_path: "jacob-square.jpg")
  end

  def self.coach_avatar_row
    avatar_row
  end

  def self.avatar_row(name: "invariant.training", photo_path: "logo.png")
    "<div><div class='flex items-center gap-3'><div style='width: 28px'><img src='/#{photo_path}' style='border-radius: 100%' /></div><div class='font-medium tracking-tight'>#{name}</div></div></div>"
  end
end