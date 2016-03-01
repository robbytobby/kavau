RSpec.shared_examples "balance" do
  it "has a default date of today" do
    expect(balance.date).to eq(Date.today)
  end

  it "date can be specified" do
    expect(balance('2013-12-02').date).to eq(Date.new(2013, 12, 02))
  end

  it "is searchable by year" do
    b1 = balance('2013-12-31')
    b2 = balance('2014-12-31')
    b3 = balance('2015-12-31')
    expect(Balance.ransack(year_eq: '2014').result).to eq([b2])
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

  it "recreates necesary balances on delete of a balance" do
    datum = Date.today.prev_year.end_of_year
    @deposit = create_deposit datum, 5000
    @balance = balance(datum)
    expect(@balance).to be_persisted
    old_id = @balance.id
    @balance.destroy
    @balance = Balance.find_by(credit_agreement_id: @credit_agreement.id, date: datum)
    expect(@balance).to be_persisted
    expect(@balance.id).not_to eq(old_id)
  end

  it "following balances are updated if balance changes" do
    @deposit = create_deposit Date.today.prev_year(3), 5000
    @balance_1, @balance_2, @balance_3 = @credit_agreement.balances.order(:date)
    @deposit.update(amount: 2000)
    @new_balance_1, @new_balance_2, @new_balance_3 = @credit_agreement.balances.order(:date)
    expect(@new_balance_1.id).to eq(@balance_1.id)
    expect(@new_balance_1.end_amount).not_to eq(@balance_1.end_amount)
    expect(@new_balance_2.id).to eq(@balance_2.id)
    expect(@new_balance_2.end_amount).not_to eq(@balance_2.end_amount)
    expect(@new_balance_3.id).to eq(@balance_3.id)
    expect(@new_balance_3.end_amount).not_to eq(@balance_3.end_amount)
  end
end

