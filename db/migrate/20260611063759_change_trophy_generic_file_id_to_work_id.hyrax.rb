class ChangeTrophyGenericFileIdToWorkId < ActiveRecord::Migration[7.2]
  def change
    rename_column :trophies, :generic_file_id, :work_id
  end
end
