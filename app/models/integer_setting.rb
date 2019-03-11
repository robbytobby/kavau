class IntegerSetting < Setting
  #validates_numericality_of :value, only_integer: true, greater_than_or_equal_to: 0, allow_nil: true
  validate :value_is_integer
  validate :value_is_greater_or_equal_to_zero

  def value
    self[:value].blank? ? self[:value] : self[:value].to_i
  end

  def form_field_partial
    return super if unit.blank?
    'settings/string_with_unit_field'
  end

  private
  def value_is_integer
    return unless value
    errors.add(:value, :not_a_number) unless self[:value].match(/\A[+-]?\d+(\.\d+)?\z/)
    errors.add(:value, :not_an_integer) unless self[:value].match(/\A[+-]?\d+\z/)
  end

  def value_is_greater_or_equal_to_zero
    return unless value
    return if errors[:value].any?
    errors.add(:value, :greater_than_or_equal_to, count: 0) unless value >= 0
  end
end
