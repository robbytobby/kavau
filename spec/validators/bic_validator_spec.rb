require 'rails_helper'

RSpec.describe AccountPolicy do
  it "knows a valid bic" do
    account = build :account, bic: 'GENODEF1S02'
    expect(account).to be_valid
  end

  it "knows a invalid bic" do
    account = build :account, bic: 'GENO'
    expect(account).not_to be_valid
    expect(account.errors[:bic]).to eq(["ist nicht gültig"])
  end
end

