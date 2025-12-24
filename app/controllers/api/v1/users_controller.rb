class Api::V1::UsersController < ApplicationController
  before_action :user, only: [:show, :destroy]

  def create
    created_user = User.create!(user_params)

    render json: {
      id: created_user.id,
      message: 'User has been created successfully'
    }, status: :created
  end

  def show
    render json: {
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      display_name: user.display_name,
      email: user.email
    }
  end

  def destroy
    user.destroy!

    render json: {
      message: 'User has been deleted successfully'
    }
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :display_name, :email, :password, :password_confirmation)
  end

  def user
    @user ||= User.find(params[:id])
  end
end
