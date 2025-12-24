# frozen_string_literal: true

class KakeiboDashboardService < BaseService
  def initialize(**args)
    @dashboard_result = args[:dashboard_result]
  end

  def call
    dashboard
  end

  private

  def dashboard
    dashboard_result
  end
end
