class Api::V1::TransactionsController < ApplicationController
  before_action :check_owned_by_current_user!, only: %i[show update destroy]

  def index
    user_transactions = current_user.transactions
    transactions = user_transactions.order(transaction_date: :desc).page(params[:page]).per(params[:per_page] || 10)
    total_income = user_transactions.joins(:category).where(categories: { category_type: :income }).sum(:amount)
    total_expense = user_transactions.joins(:category).where(categories: { category_type: :expense }).sum(:amount)

    render json: {
      transactions: transactions.map { |transaction|
        {
          id: transaction.id,
          user_id: transaction.user.display_name,
          category_id: transaction.category_id,
          category_name: transaction.category.name,
          category_type: transaction.category.category_type,
          amount: transaction.amount,
          transaction_date: transaction.transaction_date.strftime('%F'),
          note: transaction.note
        }
      },
      pagination: {
        current_page: transactions.current_page,
        total_pages: transactions.total_pages,
        total_income: total_income,
        total_expense: total_expense,
        total_count: transactions.total_count,
        per_page: transactions.limit_value
      }
    }
  end

  def create
    transaction = Transaction.create!(transaction_params)

    render json: {
      id: transaction.id,
      message: 'Transaction has been created successfully'
    }, status: :created
  end

  def show
    render json: {
      id: transaction.id,
      user_id: transaction.user.display_name,
      category_id: transaction.category.name,
      amount: transaction.amount,
      transaction_date: transaction.transaction_date.strftime('%F')
    }
  end

  def update
    transaction.update!(transaction_params)

    render json: {
      message: 'Transaction has been updated successfully',
      transaction: {
        id: transaction.id,
        user_id: transaction.user.display_name,
        category_id: transaction.category.name,
        amount: transaction.amount,
        transaction_date: transaction.transaction_date.strftime('%F')
      }
    }
  end

  def destroy
    transaction.destroy!

    render json: {
      message: 'Transaction has been deleted successfully'
    }
  end

  private

  def transaction
    @transaction ||= Transaction.find(params[:id])
  end

  def check_owned_by_current_user!
    return if transaction.owned_by?(current_user.id)

    render json: { error: 'You are not authorized to access this transaction' }, status: :forbidden
  end

  def transaction_params
    params.require(:transaction).permit(:user_id, :category_id, :amount, :transaction_date, :note)
  end
end
