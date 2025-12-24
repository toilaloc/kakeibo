# frozen_string_literal: true

class Category < ApplicationRecord
  enum category_type: { income: 0, expense: 1 }

  has_many :transactions

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :category_type, inclusion: { in: %w[income expense] }, presence: true
end
