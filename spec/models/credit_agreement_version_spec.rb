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

  it "the valid version for a date is found" do
    expect(@credit_agreement.versions.at(Date.new(2015,1,1))).to be_nil
    expect(@credit_agreement.versions.at(Date.new(2015,3,2)).reify.amount).to eq(1000)
    expect(@credit_agreement.versions.at(Date.new(2015,6,30)).reify.amount).to eq(1000)
    expect(@credit_agreement.versions.at(Date.new(2015,7,1)).reify.amount).to eq(10000)
    expect(@credit_agreement.versions.at(Date.new(2015,7,1)).reify.interest_rate).to eq(1)
    expect(@credit_agreement.versions.at(Date.new(2015,12,31)).reify.interest_rate).to eq(1)
    expect(@credit_agreement.versions.at(Date.new(2016,1,1))).to be_nil
    expect(@credit_agreement.versions.at(Date.new(2016,2,1))).to be_nil
  end

  it "filters_versions with a change in interest_rate for a given time span" do
    expect(@credit_agreement.versions.with_interest_rate_change_between(Date.new(2015,1,1), Date.new(2015,12,31)).count).to eq(0)
    expect(@credit_agreement.versions.with_interest_rate_change_between(Date.new(2015,1,1), Date.new(2016,12,31)).count).to eq(1)
  end

  it "renders the right partial" do
    @credit_agreement.versions.each do |v|
      expect(v.to_partial_path).to eq('versions/version')
    end
  end

end
