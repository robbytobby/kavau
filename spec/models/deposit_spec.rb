require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe Deposit, type: :model do
  context "the maximum amount" do
    before :each do
      @credit_agreement = create :credit_agreement, amount: 10000, valid_from: Date.today.prev_year
    end

    context "the first payment for a credit agreement" do
      it "is valid if it is the full amount" do
        deposit = build :deposit, amount: 10000, credit_agreement: @credit_agreement
        expect(deposit).to be_valid
      end

      it "is not valid if its amount is bigger than the amount of the creditagreement" do
        deposit = build :deposit, amount: 10000.1, credit_agreement: @credit_agreement
        expect(deposit).not_to be_valid
      end
    end

    context "the second payment for a creditagreement" do
      before :each do
        deposit = create :deposit, amount: 5000, credit_agreement: @credit_agreement
      end

      it "is valid if the sum of deposits is smaller or equal to the amount of the credit_agreement" do
        deposit = build :deposit, amount: 5000, credit_agreement: @credit_agreement
        expect(deposit).to be_valid
      end

      it "is not valid if the sum of deposits is bigger than the amount of the credit_agreement" do
        deposit = build :deposit, amount: 5000.1, credit_agreement: @credit_agreement
        expect(deposit).not_to be_valid
      end
    end

    context "changing a payment" do
      before :each do
        @deposit = create :deposit, amount: 5000, credit_agreement: @credit_agreement
      end

      it "is valid to change it to the max" do
        @deposit.amount = 10000
        expect(@deposit).to be_valid
      end

      it "is not valid to change it over the max" do 
        @deposit.amount = 10000.1
        expect(@deposit).not_to be_valid
      end
    end
  end

  context "the ealiest date" do
    before :each do
      @credit_agreement = create :credit_agreement, valid_from: Date.today
    end

    it "may be the same date, the credit_agreements starts on" do
      deposit = build :deposit, date: Date.today, credit_agreement: @credit_agreement
      expect(deposit).to be_valid
    end

    it "may not be before the date the credit_agreements starts on" do
      deposit = build :deposit, date: Date.yesterday, credit_agreement: @credit_agreement
      expect(deposit).not_to be_valid
    end
  end
end

