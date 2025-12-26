# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_request, :authenticate_user!, only: [:create]
      before_action :user, only: %i[show destroy]

      def create
        created_user = User.create!(user_params)

        UserMailer.welcome_email(created_user).deliver_later

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
  end
end
