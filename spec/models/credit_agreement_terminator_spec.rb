require 'rails_helper'

RSpec.describe CreditAgreementTerminator, type: :model do
  before :each do
    create :termination_letter
    allow_any_instance_of(TerminationLetter).to receive(:to_pdf).and_return(:true)
    @credit_agreement = create :credit_agreement
    @deposit = create :deposit, credit_agreement: @credit_agreement, date: Date.new(Date.today.prev_year(2).year,8,12)
  end

  describe "on terminate" do
    before :each do
      @credit_agreement.update_column(:terminated_at, Date.new(Date.today.prev_year.year,12.20))
      @terminator = CreditAgreementTerminator.new(@credit_agreement)
    end

    it "creates a termination balance" do
      @terminator.terminate
      expect(@credit_agreement.termination_balance).not_to be_nil
      expect(@credit_agreement.termination_balance.end_amount).to eq(0)
      expect(@credit_agreement.termination_balance.date).to eq(@credit_agreement.terminated_at)
    end

    it "creates a disburse" do
      expect{
        @terminator.terminate
      }.to change(@credit_agreement.payments.where(type: 'Disburse'), :count).by(1)
    end

    it "creates a pdf for the termination" do
      expect{
        @terminator.terminate
      }.to change(@credit_agreement.creditor.pdfs, :count).by(1)
      expect(@credit_agreement.creditor.pdfs.first.letter).to be_a(TerminationLetter)
    end

    it "deletes stale balances" do
      expect{
        @terminator.terminate
      }.to change(@credit_agreement.balances.where(type: 'AutoBalance'), :count).by(-1)
      expect(@credit_agreement.balances.where(type: 'AutoBalance').last.date).to eq(Date.today.prev_year(2).end_of_year)
    end
  end

  describe "on reopen" do
    before :each do
      @credit_agreement.update(terminated_at: Date.new(Date.today.prev_year.year,12.20))
      @terminator = CreditAgreementTerminator.new(@credit_agreement)
    end

    it "unsets credit_agreements termination date" do
      @terminator.reopen
      expect(@credit_agreement.terminated_at).to be_nil
    end

    it "deletes the termination disburse" do
      expect{
        @terminator.reopen
      }.to change(@credit_agreement.payments.where(type: 'Disburse'), :count).by(-1)
    end

    it "deletes the termination pdf" do
      expect{
        @terminator.reopen
      }.to change(@credit_agreement.creditor.pdfs, :count).by(-1)
    end

    it "triggers recreation of necessary balances" do
      expect{
        @terminator.reopen
      }.to change(@credit_agreement.balances.where(type: 'AutoBalance'), :count).by(1)
      expect(@credit_agreement.balances.where(type: 'AutoBalance').last.date).to eq(Date.today.prev_year.end_of_year)
    end
  end
end

