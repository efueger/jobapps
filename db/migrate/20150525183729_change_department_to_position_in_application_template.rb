class ChangeDepartmentToPositionInApplicationTemplate < ActiveRecord::Migration
  def change
    remove_column :application_templates, :department_id
    add_column :application_templates, :position_id, :integer
  end
end
