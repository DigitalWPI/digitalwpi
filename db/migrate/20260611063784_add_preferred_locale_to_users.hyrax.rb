class AddPreferredLocaleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :preferred_locale, :string
  end
end
