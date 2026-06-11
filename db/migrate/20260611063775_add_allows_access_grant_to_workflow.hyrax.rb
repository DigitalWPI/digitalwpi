class AddAllowsAccessGrantToWorkflow < ActiveRecord::Migration[7.2]
  def change
    add_column :sipity_workflows, :allows_access_grant, :boolean
  end
end
