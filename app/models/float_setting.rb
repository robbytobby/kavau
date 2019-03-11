class FloatSetting < Setting
  validate :value_is_a_number
  validate :value_is_greater_or_equal_to_zero

  def value
    self[:value].blank? ? self[:value] : self[:value].to_f
  end

  def form_field_partial
    return super if unit.blank?
    'settings/string_with_unit_field'
  end

  def value_is_a_number
    return unless value
    errors.add(:value, :not_a_number) unless self[:value].match(/\A[+-]?\d+(\.\d+)?\z/)
  end

  def value_is_greater_or_equal_to_zero
    return unless value
    return if errors[:value].any?
    errors.add(:value, :greater_than_or_equal_to, count: 0) unless value >= 0
  end
end


