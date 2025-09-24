require 'ostruct'

class AuthenticationService
  include ActiveModel::Model
  
  attr_accessor :email, :password
  
  validates :email, :password, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def initialize(email:, password:)
    @email = email
    @password = password
  end
  
  def call
    return failure(['Email and password are required']) unless valid?
    
    user = User.find_by(email: @email.downcase.strip)
    
    return failure(['Invalid email or password']) unless user&.authenticate(@password)
    
    # Optional: Check if email is verified
    # return failure(['Please verify your email address']) unless user.email_verified?
    
    token = JsonWebToken.encode(user_id: user.id)
    success(user: user, token: token)
  end
  
  private
  
  def success(data)
    OpenStruct.new(success?: true, data: data, errors: [])
  end
  
  def failure(errors)
    OpenStruct.new(success?: false, data: nil, errors: Array(errors))
  end
end
