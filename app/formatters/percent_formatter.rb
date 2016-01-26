class PercentFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    number_to_percentage @value
  end
end
