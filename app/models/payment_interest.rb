class PaymentInterest < Interest
  private
    def from_date
      @object.date
    end

    def object_amount
      @object.sign * @object.amount
    end
end
