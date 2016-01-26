class MonthFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    t 'months', count: @value
  end
end
