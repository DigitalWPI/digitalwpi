class AddColumnToBookmarks < ActiveRecord::Migration[5.2]
  def change
    add_column :bookmarks, :bookmark_category_id, :integer
  end
end
