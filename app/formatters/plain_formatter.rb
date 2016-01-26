class PlainFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    @value.to_s
  end
end
