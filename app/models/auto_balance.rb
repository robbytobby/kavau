class AutoBalance < Balance
  before_save :set_amount, :set_interest_sum

  def end_amount 
    calculated_end_amount
  end

  private
    def interest_span_class
      InterestSpan
    end

    def breakpoints
      [start, payments.pluck(:date), date].compact.flatten
    end

    def start
      return if last_years_balance.is_a?(NullBalance)
      end_of_last_year
    end

    def set_amount
      self.end_amount = calculated_end_amount
    end

    def calculated_end_amount
      sum_upto(date) + interests_sum
    end
end
