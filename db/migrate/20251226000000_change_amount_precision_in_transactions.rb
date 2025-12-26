# frozen_string_literal: true

class ChangeAmountPrecisionInTransactions < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :amount, :decimal, precision: 15, scale: 2
  end
end
