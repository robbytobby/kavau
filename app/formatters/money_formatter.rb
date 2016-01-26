class MoneyFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    number_to_currency @value
  end
end
