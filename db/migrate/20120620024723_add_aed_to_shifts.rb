class AddAedToShifts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :shifts, :aed, :boolean, :default => true
    Shift.all.each do |shift|
      shift.aed = false
      shift.save
    end
  end

  def self.down
    remove_column :shifts, :aed
  end
end
