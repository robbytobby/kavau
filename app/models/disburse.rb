class Disburse < Payment
  include ActionView::Helpers::NumberHelper
  before_save :set_sign
  validate :amount_fits

  private
    def set_sign
      self.sign = -1
    end

    def amount_fits
      return if termination_disburse?
      return if maximum_amount >= amount
      errors.add(:amount, :to_much, max: number_to_currency(maximum_amount))
    end

    def other_disburses_amount
      Disburse.where(credit_agreement_id: credit_agreement_id).where(['date > ?', date]).sum(:amount)
    end

    def maximum_amount
      AutoBalance.new(credit_agreement_id: credit_agreement_id, date: date).without(self).sum_upto(date) - other_disburses_amount  
    end

    def termination_disburse?
      amount == AutoBalance.new(credit_agreement_id: credit_agreement_id, date: date).end_amount
    end

    def not_in_the_future
      return if termination_disburse?
      super
    end
end
