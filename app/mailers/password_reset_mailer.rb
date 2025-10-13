class PasswordResetMailer < ApplicationMailer
  default from: 'noreply@vantage.com'

  def reset_password(user)
    @user = user
    @reset_url = "http://localhost:5173/reset-password?token=#{user.reset_password_token}"
    
    mail(
      to: @user.email,
      subject: 'Reset Your Vantage Password'
    )
  end
end