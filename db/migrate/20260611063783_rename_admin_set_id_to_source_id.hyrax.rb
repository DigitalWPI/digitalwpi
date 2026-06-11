class RenameAdminSetIdToSourceId < ActiveRecord::Migration[7.2]
  def change
    rename_column :permission_templates, :admin_set_id, :source_id
  end
end
