class TestJob
  include Sidekiq::Job

  def perform
    user = User.find_or_initialize_by(
      avatar_url: "/jacob.png",
      creator: true,
      email: "jake@jacobcomer.com",
      instagram_url: "https://www.instagram.com/jacob_comer",
      medium_url: "https://jacobcomer.medium.com/write-code-faster-in-vim-c564ff9b9f6c",
      name: "Jacob Comer",
      reddit_url: "https://www.reddit.com/user/jacob_the_snacob",
      subheader: "All I want is to become popular on social media, so I can quit programming and play chess all day.",
      url_code: "jacob-comerr",
      youtube_url: "https://www.youtube.com/watch?v=8NPHhAOZWGk"
    )

    user.password = "password"
    user.password_confirmation = "password"

    user.save!
  end
end