class BalanceUpdater
  def initialize(credit_agreement)
    @credit_agreement = credit_agreement
  end

  def run 
    create_missing_balances
    delete_unnecessary_balances
    update_balances
  end

  private
    def create_missing_balances
      (obligatory_balances_dates - existing_balances_dates).each do |balance_date|
        @credit_agreement.auto_balances.create!(date: balance_date)
      end
    end

    def delete_unnecessary_balances
      @credit_agreement.balances.younger_than(date_of_first_payment).destroy_all
    end

    def update_balances
      @credit_agreement.auto_balances.each(&:update_end_amount!)
    end

    def obligatory_balances_dates
      (date_of_first_payment.year...last_obligatory_year).map{ |y| Date.new(y, 12, 31) }
    end

    def last_obligatory_year
      return this_year unless @credit_agreement.terminated_at
      @credit_agreement.terminated_at.year
    end

    def existing_balances_dates
      @credit_agreement.balances.pluck(:date)
    end

    def date_of_first_payment
      (@credit_agreement.payments.first || NullPayment.new).date
    end

    def this_year
      Date.today.year
    end
end
