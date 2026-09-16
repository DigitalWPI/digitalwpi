class CreateBookmarksCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :bookmarks_categories do |t|
      t.integer :category_id, null: false
      t.integer :bookmark_id, null: false
    end
  end
end
