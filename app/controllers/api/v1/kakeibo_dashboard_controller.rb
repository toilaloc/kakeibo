# frozen_string_literal: true

module Api
  module V1
    class KakeiboDashboardController < ApplicationController
      def index
        render json: { kakeibo_dashboard: }
      end

      private

      def kakeibo_dashboard_params
        permitted_params = params.permit(:dashboard_type, :analysis_type, :start_date, :end_date)

        KakeiboDashboardParamService.new(permitted_params:).call
      end

      def kakeibo_search_results
        search_params = kakeibo_dashboard_params

        KakeiboDashboardSearchService.new(
          current_user:,
          category_type: search_params[:dashboard_type],
          start_date: search_params[:start_date],
          end_date: search_params[:end_date]
        ).call
      end

      def kakeibo_dashboard
        return {} unless (dashboard_result = kakeibo_search_results)

        KakeiboDashboardService.new(dashboard_result: dashboard_result)
      end
    end
  end
end
