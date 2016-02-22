class IntegerSetting < Setting
  validates_numericality_of :value, only_integer: true, greater_than: 0

  def value
    self[:value].to_i
  end
end
