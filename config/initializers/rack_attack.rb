Rack::Attack.safelist('allow from localhost') do |req|
  '127.0.0.1' == req.ip || '::1' == req.ip
end

Rack::Attack.blocklist('specific IP addresses') do |req|
  req.ip == '35.146.19.108'
end

Rack::Attack.throttle('req/ip', limit: 20, period: 1.minute) do |req|
  req.ip
end

# Block suspicious requests for '/etc/password' or wordpress specific paths.
# After 3 blocked requests in 10 minutes, block all requests from that IP for 30 minutes.
Rack::Attack.blocklist('fail2ban pentesters') do |req|
  # `filter` returns truthy value if request fails, or if it's from a previously banned IP
  # so the request is blocked
  Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 30.minutes) do
    # The count for the IP is incremented if the return value is truthy
    CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-includes') ||
      req.path.include?('wp-content') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login')
  end
end