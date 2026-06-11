class AddLinkedinToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :linkedin_handle, :string
  end
end
