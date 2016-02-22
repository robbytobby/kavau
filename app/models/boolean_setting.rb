class BooleanSetting < Setting
  validates_inclusion_of :value, in: ["true", "false", true, false]

  def value
    ActiveRecord::Type::Boolean.new.type_cast_from_database(self[:value])
  end

  def form_field_partial
    'settings/boolean_setting_field'
  end
end


