class CreateBookmarksCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :bookmarks_categories do |t|
      t.integer :category_id
      t.integer :bookmark_id
    end
  end
end
