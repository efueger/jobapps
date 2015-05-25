class ChangeDepartmentToPositionInApplicationRecord < ActiveRecord::Migration
  def change
    remove_column :application_records, :department_id
    add_column :application_records, :position_id, :integer
  end
end
