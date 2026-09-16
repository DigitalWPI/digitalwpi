class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :title
      t.references :user
      t.text :access_token
      t.timestamps
    end
  end
end
