class FloatSetting < Setting
  validates_numericality_of :value, greater_than_or_equal_to: 0

  def value
    self[:value].to_f
  end
end


