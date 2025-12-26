# frozen_string_literal: true

class RenameTypeInCategories < ActiveRecord::Migration[7.0]
  def change
    rename_column :categories, :type, :category_type
  end
end
