# frozen_string_literal: true

class CreateDiaryEditHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :diary_edit_histories do |t|
      t.references :diary, null: false, foreign_key: true
      t.text :content
      t.timestamps
    end
  end
end
