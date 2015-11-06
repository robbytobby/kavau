class Interest
  def initialize(object, to_date)
    @object = object
    @to_date = to_date
  end

  def amount
    return 0 if @object.nil?
    (object_amount * rate * interest_days / days_in_year).round(2)
  end

  def interest_days
    (@to_date - from_date).to_i
  end

  def days_in_year
    @to_date.end_of_year.yday
  end

  private
    def rate
      @object.credit_agreement.interest_rate / 100
    end
end
