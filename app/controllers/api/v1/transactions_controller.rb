class Api::V1::TransactionsController < ApplicationController
  before_action :owned_by_current_user?, only: %i[show update destroy]

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

  def owned_by_current_user?
    transaction.owned_by?(current_user.id)
  end

  def transaction_params
    params.require(:transaction).permit(:user_id, :category_id, :amount, :transaction_date, :note)
  end
end
