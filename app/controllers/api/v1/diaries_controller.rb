# frozen_string_literal: true

module Api
  module V1
    class DiariesController < ApplicationController
      def index
        diaries = current_user.diaries.order(date: :desc).page(params[:page]).per(params[:per_page] || 10)

        render json: {
          diaries:,
          pagination: {
            current_page: diaries.current_page,
            total_pages: diaries.total_pages,
            total_count: diaries.total_count,
            per_page: diaries.limit_value
          }
        }
      end

      def show
        render json: diary
      end

      def create
        created_diary = current_user.diaries.build(diary_params)

        if created_diary.save
          render json: created_diary, status: :created
        else
          render json: { errors: created_diary.errors }, status: :unprocessable_entity
        end
      end

      def update
        if diary.content.present?
          diary.diary_edit_histories.create!(content: diary.content)
        end

        if diary.update(diary_params)
          render json: diary
        else
          render json: { errors: diary.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        diary.destroy!

        render json: { message: 'Diary deleted successfully' }, status: :ok
      end

      private

      def diary_params
        params.require(:diary).permit(:date, :short_description, :content)
      end

      def diary
        @diary ||= current_user.diaries.find(params[:id])
      end
    end
  end
end
