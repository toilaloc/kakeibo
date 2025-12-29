# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request, :authenticate_user!

  attr_reader :current_user
  
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  private

  def authenticate_request
    token = extract_token_from_header
    return not_authorized unless token

    magic_link_service = MagicLinkService.new
    @current_user = magic_link_service.verify_and_extend_access_token(token)
  end

  def authenticate_user!
    return if current_user

    render json: {
      error: 'Unauthorized',
      message: 'You must be logged in to access this resource'
    }, status: :unauthorized
  end

  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header

    header.split(' ').last if header.start_with?('Bearer ')
  end

  def current_access_token
    extract_token_from_header
  end

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  def render_not_found(exception = nil)
    render json: { error: 'Not Found', message: exception&.message }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    record = exception.respond_to?(:record) ? exception.record : nil
    errors = record ? record.errors.full_messages : [exception.message]
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
