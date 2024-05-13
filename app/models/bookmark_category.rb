class BookmarkCategory < ApplicationRecord
  has_many :Bookmarks
  validates :title, uniqueness: { case_sensitive: false }
end
