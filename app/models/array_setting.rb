class ArraySetting < Setting
  def to_a
    value.split(',')
  end
end

