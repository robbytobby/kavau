require "rails_helper"

RSpec.describe ReverseInterestCalculator do
  describe "maximium credit for 1 year" do
    let(:calc){ ReverseInterestCalculator.new(base_amount: 100000, fund: @fund, start_date: Date.today.prev_year, end_date: Date.today) }

    [[1, 99009.9], [1.3, 98716.68], [1.5, 98522.16], [1.8, 98231.82], [2.0, 98039.21]].each do |rate, expected|
      it "is #{expected} if interest_rate is #{rate}" do
        @fund = create :fund, interest_rate: rate
        expect(calc.maximum_credit.to_f).to eq expected
      end
    end
  end

  describe "maximium credit for 244 days" do
    let(:calc){ ReverseInterestCalculator.new(base_amount: 100000, fund: @fund, start_date: Date.today.prev_day(244), end_date: Date.today) }

    [[1, 99337.74], [1.3, 99140.77], [1.5, 99009.90], [1.8, 98814.22], [2.0, 98684.21]].each do |rate, expected|
      it "is #{expected} if interest_rate is #{rate}" do
        @fund = create :fund, interest_rate: rate
        expect(calc.maximum_credit.to_f).to eq expected
      end
    end
  end
end
