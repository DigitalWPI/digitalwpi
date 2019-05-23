class CreateEprojectRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :eproject_records do |t|
      t.string :eprojects_id
      t.string :work_id
      t.integer :status

      t.timestamps
    end
    add_index :eproject_records, :eprojects_id
    add_index :eproject_records, :work_id
  end
end
