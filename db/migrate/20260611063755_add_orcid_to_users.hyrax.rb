class AddOrcidToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :orcid, :string
  end
end
