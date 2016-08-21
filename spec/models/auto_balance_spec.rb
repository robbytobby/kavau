require 'rails_helper'

RSpec.describe AutoBalance, type: :model do
  before :each do
    @credit_agreement = create :credit_agreement, interest_rate: 2, valid_from: Date.new(2013,1,1)
    dont_validate_fund_for CreditAgreement
  end

  it_behaves_like "balance" 

  describe "interest_spans" do
    it "has 1 interest span if no payments for the year exist" do
      create_deposit Date.new(2013,12,1), 1000
      expect(balance(Date.new(2014,12,31)).interest_spans.count).to eq(1)
    end

    it "for the first year begins with the first payment" do
      create_deposit Date.new(2013,12,1), 1000
      spans = balance(Date.new(2013,12,31)).interest_spans
      expect(spans.count).to eq(1)
      expect(spans.first.start_date).to eq(Date.new(2013,12,1))
      expect(spans.first.end_date).to eq(Date.new(2013,12,31))
    end

    it "there's none for paymement at the balances date" do
      create_deposit Date.new(2013,12,31), 1000
      spans = balance(Date.new(2013,12,31)).interest_spans
      expect(spans.count).to eq(0)
    end

    it "there is one for a pament at the first of january" do
      create_deposit Date.new(2013,1,1), 1000
      create_deposit Date.new(2014,1,1), 1000
      spans = balance(Date.new(2014,12,31)).interest_spans
      expect(spans.count).to eq(2)
      expect(spans.first.start_date).to eq(Date.new(2013,12,31))
      expect(spans.first.end_date).to eq(Date.new(2014,1,1))
    end

    it "there is one for each payment" do
      create_deposit Date.new(2013,1,1), 1000
      create_deposit Date.new(2014,2,1), 1000
      create_deposit Date.new(2014,4,1), 1000
      create_deposit Date.new(2014,6,1), 1000
      create_deposit Date.new(2014,8,1), 1000
      spans = balance(Date.new(2014,12,31)).interest_spans
      expect(spans.count).to eq(5)
    end

    it "there is none for payment at the same date" do
      create_deposit Date.new(2013,1,1), 1000
      create_deposit Date.new(2014,2,1), 1000
      create_deposit Date.new(2014,2,1), 1000
      spans = balance(Date.new(2014,12,31)).interest_spans
      expect(spans.count).to eq(2)
    end

    with_versioning do
      describe "with change of credit_agreement" do
        it "there is no extra one if interest rate did not change" do
          create_deposit Date.new(2015, 3, 2), 1000
          @credit_agreement.update_attributes!(amount: 19999, valid_from: Date.new(2015, 7, 1))
          spans = balance(Date.new(2015,12,31)).interest_spans
          expect(spans.count).to eq(1)
        end

        it "there is no extra one if interest rate did not change in the correspoinding time span" do
          create_deposit Date.new(2015, 3, 2), 1000
          @credit_agreement.update_attributes!(interest_rate: 1.9, valid_from: Date.new(2014, 7, 1))
          spans = balance(Date.new(2015,12,31)).interest_spans
          expect(spans.count).to eq(1)
        end
      end
    end
  end

  describe "end_amount" do
    it "is 0 for a new credit_agreement" do
      expect(balance.end_amount).to eq(0)
    end

    it "includes deposits on the credit_agreement" do
      create_deposit Date.today, 5000
      expect(balance.end_amount).to eq(5000)
    end

    it "does not include deposits on other credit_agreements" do
      other_deposit = create :deposit, amount: 1111, date: Date.today
      expect(balance.end_amount).to eq(0)
    end

    it "includes disburses on the credit_agreement" do
      create_deposit Date.today, 5000
      create_disburse Date.today, 2000
      expect(balance.end_amount).to eq(3000)
    end

    it "does not include disburses on other credit_agreements" do
      create_deposit Date.today, 5000
      create_disburse Date.today, 2000
      other_deposit = create :deposit, amount: 3333, date: Date.today
      other_disburse = create :disburse, amount: 1111, date: Date.today, credit_agreement: other_deposit.credit_agreement
      expect(balance.end_amount).to eq(3000)
    end

    it "does not take future payments into account" do
      create_deposit '2015-10-10', 5000
      create_deposit Date.today, 5000
      create_disburse '2015-10-10', 2000
      create_disburse Date.today, 1000
      expect(balance('2015-10-10').end_amount).to eq(3000)
    end

    it "gets updated if according payments are updated" do
      @deposit = create_deposit Date.today.beginning_of_year.prev_day, 5000
      expect(balance(Date.today.end_of_year).end_amount).to eq(5100)
      @credit_agreement.reload
      @deposit.update(amount: 1000)
      expect(balance(Date.today.end_of_year).end_amount).to eq(1020)
    end

    it "gets updated on all later balances, if a previous balance is updated" do
      @deposit = create_deposit Date.today.end_of_year.prev_year(2), 5000
      expect(@credit_agreement.reload.balances.count).to eq(2)
      @balance_1, @balance_2 = @credit_agreement.balances.order(:date)
      @balance_1.becomes_manual_balance.save
      @balance_1 = Balance.find(@balance_1.id)
      @balance_1.update(end_amount: 6000)
      @new_balance_1, @new_balance_2 = @credit_agreement.balances.order(:date)
      expect(@new_balance_2.end_amount).not_to eq(@balance_2.end_amount)
    end

    (1..5).map(&:to_d).each do |rate|
      context "complicated_settings" do
        before :each do
          @credit_agreement = create :credit_agreement, interest_rate: rate
        end

        it "calculates correctly" do
          old_deposit = create_deposit Date.today.beginning_of_year.prev_day(31), 20000
          old_disburse = create_disburse Date.today.beginning_of_year.prev_day(21), 10000
          old_end_amount = 20000 - 10000 +
            interest(20000, rate, 10, total_days(old_deposit.date))+
            interest(10000, rate, 20, total_days(old_deposit.date))
          expect(balance(Date.today.prev_year.end_of_year).end_amount).to eq(old_end_amount)
          new_deposit = create_deposit Date.today.beginning_of_year, 22222
          new_deposit.update_column(:date, Date.today.beginning_of_year.next_day(100))
          new_disburse = create_disburse Date.today.beginning_of_year, 10001
          new_disburse.update_column(:date, Date.today.beginning_of_year.next_day(200))
          new_end_amount = old_end_amount + 22222 - 10001 +
            interest(old_end_amount, rate, 101) +
            interest(old_end_amount + 22222, rate, 100) +
            interest(old_end_amount + 22222 - 10001, rate, Date.today.end_of_year.yday - 201)
          expect(balance(Date.today.end_of_year).end_amount).to eq(new_end_amount)
        end

        it "calculates correctly since start of year" do
          create_deposit '2015-01-01', 10000
          expect(balance('2015-01-31').end_amount).to eq(10000 + interest(10000, rate, 30, 365))
        end

        it "calculates correctly for the closing of year balance" do
          create_deposit '2014-12-1', 10000
          expect(balance('2014-12-31').end_amount).to eq(10000 + interest(10000, rate, 30, 365))
        end
      end
    end
  end

  describe "interest_sum" do
    (1..5).map(&:to_d).each do |rate|
      context "rate #{rate}%" do
        before :each do
          @credit_agreement = create :credit_agreement, interest_rate: rate, valid_from: Date.new(2014,1,1)
        end

        context "interest_sum" do
          it "interest is 0 for todays payment" do
            create_deposit '2015-10-31', 5000
            expect(balance('2015-10-31').interests_sum).to eq(0)
          end

          it "takes a deposit into account" do
            create_deposit '2015-10-1', 5000
            expect(balance('2015-10-31').interests_sum).to eq(interest(5000, rate, 30, 365))
          end

          it "takes  a disburse into account" do
            create_deposit '2015-10-1', 5000
            create_disburse '2015-10-1', 2000
            expect(balance('2015-10-31').interests_sum).to eq(interest(3000, rate, 30, 365))
          end

          it "takes last years balance into account" do
            create_deposit '2014-10-1', 10000
            last_years_end_amount = 10000 + interest(10000, rate, 91, 365)
            create_deposit '2015-01-10', 5000
            create_disburse '2015-01-20', 2000
            expect(balance('2015-01-31').interests_sum).to eq(
              interest(last_years_end_amount, rate, 10, 365) +
              interest(last_years_end_amount + 5000, rate, 10, 365) +
              interest(last_years_end_amount + 5000 - 2000, rate, 11, 365)
            )
          end
        end
      end
    end
  end

  def balance(date = Date.today)
    AutoBalance.find_or_create_by(credit_agreement_id: @credit_agreement.id, date: date)
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def interest(amount, rate, num_days, total_num_days = total_days)
    (amount.to_d * rate / 100 * num_days / total_num_days).round(2)
  end

  def total_days(date = Date.today)
    date.end_of_year.yday
  end
end

