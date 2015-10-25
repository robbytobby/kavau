require 'rails_helper'

RSpec.describe AccountPolicy do
  it "knows a valid iban" do
    account = build :account, iban: 'DE20 6009 0800 0004 1576 70'
    expect(account).to be_valid
  end

  it "knows a invalid bic" do
    account = build :account, iban: 'DE20 6009 0800 0004 1576'
    expect(account).not_to be_valid
    expect(account.errors[:iban]).to eq(["ist nicht gültig"])
  end
end


