class ManualBalance < Balance
  before_save :set_interest_sum

  private
    def interest_span_class
      ManualInterestSpan
    end

    def breakpoints
      [start, date] 
    end

    def start
      return date.beginning_of_year.prev_day if !last_years_balance.is_a?(NullBalance) || payments.none?
      payments.first.date
    end

    def set_amount
    end
end
