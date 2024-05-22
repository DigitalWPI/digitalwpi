class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :title
      t.references :user
      t.string :access_token
      t.timestamps
    end
  end
end
