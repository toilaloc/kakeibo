# frozen_string_literal: true

class CreateDiaries < ActiveRecord::Migration[7.0]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :short_description
      t.text :content
      t.timestamps
    end
    add_index :diaries, [:user_id, :date], unique: true
  end
end