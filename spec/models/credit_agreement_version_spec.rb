require 'rails_helper'

RSpec.describe CreditAgreementVersion do
  before :each do
    @credit_agreement = create :credit_agreement, valid_from: Date.new(2015, 3, 2), interest_rate: 1, amount: 1000
    dont_validate_fund_for CreditAgreement
    with_versioning do
      @credit_agreement.update_attributes(amount: 10000, valid_from: Date.new(2015, 7, 1))
      @credit_agreement.update_attributes(interest_rate: 2, valid_from: Date.new(2016, 1, 1))
    end
  end

  it "renders the right partial" do
    @credit_agreement.versions.each do |v|
      expect(v.to_partial_path).to eq('versions/version')
    end
  end

end
