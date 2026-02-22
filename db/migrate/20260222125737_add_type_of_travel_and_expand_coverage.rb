class AddTypeOfTravelAndExpandCoverage < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :insurance_policies, name: "chk_coverage_tier"
    add_check_constraint :insurance_policies,
      "coverage_tier >= 1 AND coverage_tier <= 4", name: "chk_coverage_tier"
    add_column :insurance_policies, :type_of_travel, :integer, null: false, default: 1
  end
end
