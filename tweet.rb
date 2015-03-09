class Tweet
  attr_accessor :body

  def initialize(body)
    @body = body
  end

  def self.create(params)
    @description = params[:description]
  end
end

class User
  attr_accessor :user_id, :email

  @@user_id = 0
  def initialize(email, password)
    @user_id = @@user_id
    @@user_id += 1
    @email = email
  end
end

# first_user = User.new('t@example.com', '12345678')
# p first_user.user_id
# p first_user.email

# first_tweet = Tweet.new('this is a new tweet')
# p first_tweet.body

Tweet.new()
