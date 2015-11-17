require 'rails_helper'

RSpec.describe Balance, type: :model do
  before :each do
    @credit_agreement = create :credit_agreement, interest_rate: 2
  end

  it_behaves_like "balance"

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def balance(date = Date.today)
    @credit_agreement.balances.reload.find_or_create_by(date: date, type: 'AutoBalance')
  end
end
