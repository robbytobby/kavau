require 'rails_helper'

RSpec.describe Balance, type: :model do
  before :each do
    @credit_agreement = create :credit_agreement, interest_rate: 2
  end

  it "has a default date of today" do
    expect(balance.date).to eq(Date.today)
  end

  it "date can be specified" do
    expect(balance('2013-12-02').date).to eq(Date.new(2013, 12, 02))
  end

  describe "start_amount" do
    it "is 0 if no payments from previous years exist" do
      create_deposit Date.today, 5000
      expect(balance.start_amount).to eq(0)
    end

    it "is the end amount of last year if payments from previous years exist" do
      create_deposit Date.today.beginning_of_year.prev_day, 5000
      expect(balance.start_amount).to eq(5000)
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

    it "does not include dispurses on other credit_agreements" do
      create_deposit Date.today, 5000
      create_disburse Date.today, 2000
      other_disburse = create :disburse, amount: 1111, date: Date.today
      expect(balance.end_amount).to eq(3000)
    end

    it "does not take future payments into account" do
      create_deposit '2015-10-10', 5000
      create_deposit Date.today, 5000
      create_disburse '2015-10-10', 2000
      create_disburse Date.today, 1000
      expect(balance('2015-10-10').end_amount).to eq(3000)
    end

    context "interest calculations" do
      (1..5).map(&:to_d).each do |rate|
        context "rate #{rate}%" do
          before :each do
            @credit_agreement = create :credit_agreement, interest_rate: rate
          end

          context "interest_sum" do
            it "interest is 0 for todays payment" do
              create_deposit '2015-10-31', 5000
              expect(balance('2015-10-31').interests_sum).to eq(0)
            end

            it "takes interest for a deposit into account" do
              create_deposit '2015-10-1', 5000
              expect(balance('2015-10-31').interests_sum).to eq(interest(5000, rate, 30))
            end

            it "takes interest for a disburse into account" do
              create_deposit '2015-10-1', 5000
              create_disburse '2015-10-1', 2000
              expect(balance('2015-10-31').interests_sum).to eq(interest(3000, rate, 30))
            end

            it "takes last years balance into account" do
              create_deposit '2014-10-1', 10000
              last_years_end_amount = 10000 + interest(10000, rate, 91)
              create_deposit '2015-01-10', 5000
              create_disburse '2015-01-20', 2000
              expect(balance('2015-01-31').interests_sum).to eq(
                interest(last_years_end_amount, rate, 10) +
                interest(last_years_end_amount + 5000, rate, 10) +
                interest(last_years_end_amount + 5000 - 2000, rate, 11)
              )
            end
          end

          context "end_amount" do
            it "calculates correctly for complicated settings" do
              old_deposit = create_deposit Date.today.beginning_of_year.prev_day(31), 20000
              old_disburse = create_disburse Date.today.beginning_of_year.prev_day(21), 10000
              old_end_amount = 20000 - 10000 +
                interest(20000, rate, 10)+
                interest(10000, rate, 20)
              new_deposit = create_deposit Date.today.beginning_of_year.next_day(100), 22222
              new_disburse = create_disburse Date.today.beginning_of_year.next_day(200), 12345
              new_end_amount = old_end_amount + 22222 - 12345 +
                interest(old_end_amount, rate, 101) +
                interest(old_end_amount + 22222, rate, 100) +
                interest(old_end_amount + 22222 - 12345, rate, Date.today.end_of_year.yday - 201)
              expect(balance(Date.today.end_of_year).end_amount).to eq(new_end_amount)
            end

            it "calculates correctly since start of year" do
              create_deposit '2015-01-01', 10000
              expect(balance('2015-01-31').end_amount).to eq(10000 + interest(10000, rate, 30))
            end

            it "calculates correctly for the closing of year balance" do
              create_deposit '2014-12-1', 10000
              expect(balance('2014-12-31').end_amount).to eq(10000 + interest(10000, rate, 30))
            end
          end
        end
      end
    end
  end

  def create_deposit(date, amount)
    create :deposit, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def create_disburse(date, amount)
    create :disburse, credit_agreement: @credit_agreement, date: date, amount: amount
  end

  def balance(date = Date.today)
    create :balance, credit_agreement: @credit_agreement, date: date
  end

  def interest(amount, rate, num_days, total_num_days = total_days)
    (amount.to_d * rate / 100 * num_days / total_num_days).round(2)
  end

  def total_days(date = Date.today)
    date.end_of_year.yday
  end
end
