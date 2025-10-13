class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register, :forgot_password, :reset_password]
  
  # POST /api/v1/auth/login
  def login
    result = AuthenticationService.new(
      email: login_params[:email],
      password: login_params[:password]
    ).call
    
    if result.success?
      render json: {
        success: true,
        message: 'Login successful',
        data: {
          user: user_response(result.data[:user]),
          token: result.data[:token]
        }
      }
    else
      render_error(result.errors, 'Login failed', :unauthorized)
    end
  end
  
  # POST /api/v1/auth/register
  def register
    user = User.new(register_params)
    
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        success: true,
        message: 'Registration successful',
        data: {
          user: user_response(user),
          token: token
        }
      }, status: :created
    else
      render_error(user.errors.full_messages, 'Registration failed')
    end
  end
  
  # DELETE /api/v1/auth/logout
  def logout
    # With JWT, logout is handled client-side by removing the token
    # Optionally, you could implement a token blacklist here
    render_success(nil, 'Logout successful')
  end
  
  # GET /api/v1/auth/profile
  def profile
    render json: {
      success: true,
      message: 'Profile retrieved successfully',
      data: {
        user: user_response(current_user)
      }
    }
  end
  
  # PUT /api/v1/auth/profile
  def update_profile
    if current_user.update(profile_params)
      render json: {
        success: true,
        message: 'Profile updated successfully',
        data: {
          user: user_response(current_user)
        }
      }
    else
      render_error(current_user.errors.full_messages, 'Profile update failed')
    end
  end
  
  # POST /api/v1/auth/forgot_password
 def forgot_password
  return render_error(['Email is required'], 'Email required') if params[:email].blank?
  
  user = User.find_by(email: params[:email].downcase.strip)
  
  if user
    user.generate_reset_password_token!
    
    # Send email
    PasswordResetMailer.reset_password(user).deliver_later
    
    render_success(nil, 'Password reset instructions sent to your email')
  else
    render_success(nil, 'If the email exists, password reset instructions have been sent')
  end
 end
  
  
  # PUT /api/v1/auth/reset_password
  def reset_password
    user = User.find_by(reset_password_token: params[:token])
    
    unless user&.reset_password_token_valid?
      return render_error(['Invalid or expired reset token'], 'Token invalid')
    end
    
    if user.update(
      password: params[:password], 
      reset_password_token: nil, 
      reset_password_sent_at: nil
    )
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        success: true,
        message: 'Password reset successful',
        data: {
          user: user_response(user),
          token: token
        }
      }
    else
      render_error(user.errors.full_messages, 'Password reset failed')
    end
  end
  
  # PUT /api/v1/auth/change_password
  def change_password
    unless current_user.authenticate(params[:current_password])
      return render_error(['Current password is incorrect'], 'Invalid password', :unauthorized)
    end
    
    if params[:password].blank?
      return render_error(['New password cannot be blank'], 'Password required')
    end
    
    if params[:password] != params[:password_confirmation]
      return render_error(['Passwords do not match'], 'Password mismatch')
    end
    
    if current_user.update(password: params[:password])
      render_success(nil, 'Password changed successfully')
    else
      render_error(current_user.errors.full_messages, 'Password change failed')
    end
  end
  
  private
  
  def login_params
    params.require(:auth).permit(:email, :password)
  end
  
  def register_params
    params.require(:auth).permit(:email, :password, :first_name, :last_name)
  end
  
  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, preferences: {})
  end
  
  def user_response(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      email_verified: user.email_verified,
      preferences: user.preferences,
      created_at: user.created_at
    }
  end
end
