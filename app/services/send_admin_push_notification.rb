class SendAdminPushNotification
  def self.call(title, message, notification_url = nil)
    url = URI.parse("https://api.pushover.net/1/messages.json")
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      token: ENV["PUSHOVER_API_KEY"],
      user: ENV["PUSHOVER_USER_KEY"],
      title: title,
      message: message,
      url: notification_url
    })
    res = Net::HTTP.new(url.host, url.port)
    res.use_ssl = true
    res.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res.start {|http| http.request(req) }
  end
end