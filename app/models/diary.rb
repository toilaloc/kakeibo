# frozen_string_literal: true

class Diary < ApplicationRecord
  belongs_to :user
  has_many :diary_edit_histories, dependent: :destroy

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }
end
