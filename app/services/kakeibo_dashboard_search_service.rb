# frozen_string_literal: true

class KakeiboDashboardSearchService < BaseService
  def initialize(**args)
    @user                 = args[:current_user]
    @start_date           = args[:start_date]
    @end_date             = args[:end_date]
    @category_type        = args[:category_type]
  end

  def call
    search_results
  end

  private

  def search_results
    @user.transactions
         .joins(:category)
         .where(search_query, start_date: @start_date, end_date: @end_date, category_type: @category_type)
         .select(selected_fields)
         .distinct
  end

  def search_query
    <<-SQL
      transactions.transaction_date BETWEEN :start_date AND :end_date
                       AND categories.category_type IN (:category_type)
    SQL
  end

  def selected_fields
    <<-SQL
      transactions.id,
      transactions.amount,
      transactions.transaction_date,
      transactions.note,
      categories.name AS category_name,
      categories.category_type AS category_type
    SQL
  end
end
