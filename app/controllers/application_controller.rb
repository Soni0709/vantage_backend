class ApplicationController < ActionController::API
  before_action :authenticate_request, except: [:health_check]
  
  attr_reader :current_user
  
  def health_check
    render json: { 
      success: true, 
      message: 'Vantage Backend API is running',
      version: '1.0.0'
    }, status: :ok
  end
  
  private
  
  def authenticate_request
    token = extract_token_from_header
    return render_unauthorized('No token provided') unless token
    
    decoded_token = JsonWebToken.decode(token)
    return render_unauthorized('Invalid token') unless decoded_token
    
    @current_user = User.find_by(id: decoded_token[:user_id])
    return render_unauthorized('User not found') unless @current_user
    
  rescue ActiveRecord::RecordNotFound
    render_unauthorized('User not found')
  rescue => e
    Rails.logger.error "Authentication error: #{e.message}"
    render_unauthorized('Authentication failed')
  end
  
  def extract_token_from_header
    auth_header = request.headers['Authorization']
    auth_header&.split(' ')&.last
  end
  
  def render_unauthorized(message = 'Unauthorized')
    render json: { 
      success: false, 
      message: message,
      errors: [message] 
    }, status: :unauthorized
  end
  
  def render_success(data = nil, message = 'Success', status = :ok)
    response = { success: true, message: message }
    response[:data] = data if data
    render json: response, status: status
  end
  
  def render_error(errors, message = nil, status = :unprocessable_entity)
    render json: { 
      success: false, 
      message: message || Array(errors).first,
      errors: Array(errors)
    }, status: status
  end
end
