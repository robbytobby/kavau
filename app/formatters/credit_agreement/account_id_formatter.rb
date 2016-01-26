class AccountIdFormatter < AttributeFormatter
  def formatted_value
    return if @value.blank?
    Account.find(@value).name
  end
end
