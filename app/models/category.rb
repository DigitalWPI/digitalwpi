class Category < ApplicationRecord
  belongs_to :user
  has_many :bookmarks_categories, dependent: :destroy
  has_many :bookmarks, through: :bookmarks_categories
  validates :title, uniqueness: { case_sensitive: false }
end
