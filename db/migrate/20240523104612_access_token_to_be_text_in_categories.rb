class AccessTokenToBeTextInCategories < ActiveRecord::Migration[5.2]
  def change
    change_column :categories, :access_token, :text
  end
end
