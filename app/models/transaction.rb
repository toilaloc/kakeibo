# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_date, presence: true

  def owned_by?(current_user_id)
    user_id == current_user_id
  end
end
