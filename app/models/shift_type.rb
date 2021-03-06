# == Schema Information
# Schema version: 20110222181535
#
# Table name: shift_types
#
#  id                    :integer         primary key
#  name                  :string(255)
#  primary_requirement   :integer
#  secondary_requirement :integer
#  created_at            :timestamp
#  updated_at            :timestamp
#  ignore_primary        :boolean
#

class ShiftType < ActiveRecord::Base
  has_many :shifts, :dependent => :destroy

  validates :name, :presence => true
  validates_numericality_of :primary_requirement, :presence => true
  validates_numericality_of :secondary_requirement, :presence => true
  validates_numericality_of :critical_time, :presence => true, :greater_than_or_equal_to => 0

  def self.suspended_allowed
    ShiftType.where(:ignore_suspended => true)
  end

  def self.primary_ignored
    ShiftType.where(:ignore_primary => true);
  end

  def as_json(user = nil)
    json = {
      :id => self.id,
      :name => self.name,
    }

    unless user.nil?
      json[:quota] = user.hours_quota(self)
      json[:hours] = user.total_hours(self)
    end

    return json
  end

  def critical_days
    critical_time * 1.day
  end

  def hours_filled
    primary_filled = Shift.where('shift_type_id = ? AND primary_id IS NOT NULL', id).map(&:length).reduce{|a,b| a+b} || 0
    secondary_filled = Shift.where('shift_type_id = ? AND secondary_id IS NOT NULL', id).map(&:length).reduce{|a,b| a+b} || 0
    return primary_filled + secondary_filled
  end

  def make_default
    ShiftType.all.each do |shift_type|
      shift_type.default = false
      shift_type.save
    end

    self.default = true
    self.save
  end

  def self.get_default
    if ShiftType.find_by default: true != nil
      return ShiftType.find_by(default: true).id
    else
      return 0
    end
  end
end
