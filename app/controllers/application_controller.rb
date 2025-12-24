class ApplicationController < ActionController::API
  before_action :authenticate_request, except: %i(request_magic_link verify)

  attr_reader :current_user
  
  private
  
  def authenticate_request
    token = extract_token_from_header
    return not_authorized unless token
    
    magic_link_service = MagicLinkService.new
    @current_user = magic_link_service.verify_and_extend_access_token(token)
  end
  
  def authenticate_user!
    unless current_user
      render json: { 
        error: 'Unauthorized',
        message: 'You must be logged in to access this resource'
      }, status: :unauthorized
    end
  end
  
  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header
    
    header.split(' ').last if header.start_with?('Bearer ')
  end
  
  def current_access_token
    extract_token_from_header
  end

  private

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end
end
