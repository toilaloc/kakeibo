# frozen_string_literal: true

class AddContentToDiaries < ActiveRecord::Migration[7.0]
  def change
    add_column :diaries, :content, :text
  end
end