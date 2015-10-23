require 'rails_helper'

RSpec.describe "creditors index view" do
  before :each do 
    login_as create(:accountant) 
    @creditor = create :person
    @credit_agreement = create(:credit_agreement, creditor: @creditor)
  end

  context "coming from the creditor show page" do
    it "successfull edit redirects back to the creditor" do
      visit person_path(@creditor)
      click_on "edit_credit_agreement_#{@credit_agreement.id}"
      expect(current_path).to eq(edit_person_credit_agreement_path(@creditor, @credit_agreement))
      click_on :submit
      expect(current_path).to eq(person_path(@creditor))
    end

    it "successfull delete redirects to the creditro" do
      visit person_path(@creditor)
      click_on "delete_credit_agreement_#{@credit_agreement.id}"
      expect(current_path).to eq(person_path(@creditor))
    end
  end

  context "coming from the credit_agreements indes" do
    it "succesfull edit redirects back to the credit_agreements index" do
      visit credit_agreements_path
      click_on "edit_credit_agreement_#{@credit_agreement.id}"
      expect(current_path).to eq(edit_person_credit_agreement_path(@creditor, @credit_agreement))
      click_on :submit
      expect(current_path).to eq(credit_agreements_path)
    end

    it "succesfull delete redirects back to the credit_agreements index" do
      visit credit_agreements_path
      click_on "delete_credit_agreement_#{@credit_agreement.id}"
      expect(current_path).to eq(credit_agreements_path)
    end
  end
end

