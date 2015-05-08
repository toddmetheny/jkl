class Session
  def initialize(username, token)
    @username = username
    @token = token
  end
  
  def current_user
    @current_user = { username: @username, token: @token }
  end

  def login
  end
end

# s = Session.new("Bill", "445323423")
# puts s.current_user
