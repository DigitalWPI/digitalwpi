# This migration comes from devise_multi_auth (originally 20140204141526)
class CreateAuthentications < ActiveRecord::Migration[5.1]
  def change
    create_table :devise_multi_auth_authentications do |t|
      t.integer :user_id, index: true, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :access_token
      t.string :refresh_token
      t.timestamp :expires_at, index: true
      t.timestamps
    end
    add_index :devise_multi_auth_authentications, [:provider, :uid], unique: true
  end
end
