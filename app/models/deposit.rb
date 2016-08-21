class Deposit < Payment
  before_save :set_sign
  validate :maximum_credit_amount, :not_before_credit_agreement_starts
  
  private
    def not_before_credit_agreement_starts
      errors.add(:date, :not_before, date: I18n.l(credit_agreement.valid_from)) if date < credit_agreement.valid_from
    end

    def maximum_credit_amount
      errors.add(:amount, :to_much, max: error_max) if change_amount > max
    end

    def set_sign
      self.sign = 1
    end

    def max
      credit_agreement.amount - Deposit.where(credit_agreement_id: credit_agreement_id).sum(:amount)
    end

    def change_amount
      return amount if new_record?
      amount - amount_was
    end

    def error_max
      return max if new_record?
      max + amount_was
    end
end
