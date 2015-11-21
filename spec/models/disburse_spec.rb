require 'rails_helper'

RSpec.describe Disburse do
  before(:each){ @credit_agreement = create :credit_agreement, interest_rate: 2 }

  context "may never make the credit agreements end_amount negative" do
    it "a disburse without any deposit" do
      @disburse = build :disburse, amount: 1, credit_agreement: @credit_agreement
      expect(@disburse).not_to be_valid
      expect(@disburse.errors.messages[:amount].first).to eq("zu groß (max 0,00 €)")
    end

    it "a disburse smaller than or equal to the previous deposit is valid" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today
      @disburse = build :disburse, amount: 100, credit_agreement: @credit_agreement, date: Date.today
      expect(@disburse).to be_valid 
    end

    it "a disburse greater than the previous deposit" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today
      @disburse = build :disburse, amount: 100.01, credit_agreement: @credit_agreement, date: Date.today
      expect(@disburse).not_to be_valid 
      expect(@disburse.errors.messages[:amount].first).to eq("zu groß (max 100,00 €)")
    end

    it "a disburse greater than the amount available including interest" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today.prev_year.end_of_year
      @disburse = build :disburse, amount: 102.01, credit_agreement: @credit_agreement, date: Date.today.end_of_year
      expect(@disburse).not_to be_valid 
      expect(@disburse.errors.messages[:amount].first).to eq("zu groß (max 100,00 €)")
    end

    it "can be updated if amount still fits" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today
      @disburse = create :disburse, amount: 50, credit_agreement: @credit_agreement, date: Date.today
      @disburse.amount = 100
      expect(@disburse).to be_valid 
    end

    it "cannot be updated if amount does not fit anymore" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today
      @disburse = create :disburse, amount: 50, credit_agreement: @credit_agreement, date: Date.today
      @disburse.amount = 101
      expect(@disburse).not_to be_valid 
      expect(@disburse.errors.messages[:amount].first).to eq("zu groß (max 100,00 €)")
    end

    it "is invalid if allready existing diburses would lead to negative balances" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today.beginning_of_year
      create :disburse, amount: 50, credit_agreement: @credit_agreement, date: Date.today
      @disburse = build :disburse, amount: 55, credit_agreement: @credit_agreement, date: Date.today.prev_day
      expect(@disburse).not_to be_valid 
      expect(@disburse.errors.messages[:amount].first).to eq("zu groß (max 50,00 €)")
    end

    it "it is valid if it fits including allready existing disburses" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today.beginning_of_year
      create :disburse, amount: 50, credit_agreement: @credit_agreement, date: Date.today
      @disburse = build :disburse, amount: 50, credit_agreement: @credit_agreement, date: Date.today.prev_day
      expect(@disburse).to be_valid 
    end

    it "it is valid if it takes all including interest" do
      create :deposit, credit_agreement: @credit_agreement, amount: 100, date: Date.today.prev_year(2).end_of_year
      @disburse = build :disburse, amount: 102, credit_agreement: @credit_agreement, date: Date.today.prev_year.end_of_year
      expect(@disburse).to be_valid 
    end
  end
end
