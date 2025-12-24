class KakeiboDashboardParamService < BaseService
  DASHBOARD_TYPE = %w[income expense all].freeze
  ANALYSIS_TYPE  = %w[1_month 6_month 12_month custom].freeze

  attr_reader :permitted_params

  def initialize(permitted_params:)
    @permitted_params = permitted_params
  end

  def call
    raise ArgumentError, 'Invalid parameters' if permitted_params.blank?

    validate_params
    set_params
  end

  private

  def validate_params
    return if DASHBOARD_TYPE.include?(permitted_params[:dashboard_type]) && ANALYSIS_TYPE.include?(permitted_params[:analysis_type])

    raise ArgumentError, 'Invalid dashboard_type or analysis_type'
  end

  def set_params
    permitted_params.tap do |params|
      params[:dashboard_type] = if permitted_params[:dashboard_type] == 'all'
                                  %w[income expense]
                                else
                                  permitted_params[:dashboard_type]
                                end

      case permitted_params[:analysis_type]
      when '1_month'
        params[:start_date] = Date.current.beginning_of_month
        params[:end_date]   = Date.current.end_of_month
      when '6_month'
        params[:start_date] = 6.months.ago.to_date.beginning_of_day
        params[:end_date]   = Date.current.end_of_day
      when '12_month'
        params[:start_date] = 12.months.ago.to_date.beginning_of_day
        params[:end_date]   = Date.current.end_of_day
      when 'custom'
        raise ArgumentError, 'Invalid date format' unless valid_date?

        params[:start_date] = permitted_params[:start_date].to_date.beginning_of_day
        params[:end_date]   = permitted_params[:end_date].to_date.end_of_day
      end
    end
  end

  def valid_date?
    Date.parse(permitted_params[:start_date]) && Date.parse(permitted_params[:end_date])
  rescue ArgumentError
    false
  end
end
