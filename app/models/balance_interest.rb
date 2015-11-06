class BalanceInterest < Interest
  private
    def from_date
      @to_date.beginning_of_year - 1.day
    end

    def object_amount
      @object.end_amount
    end
end
