class DateFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    l @value.to_date
  end
end
