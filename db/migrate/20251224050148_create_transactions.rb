class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :user
      t.references :category
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :transaction_date, null: false
      t.string :note
      t.timestamps
    end
  end
end
