require 'rails_helper'

RSpec.describe Payment, type: :model do
  it "valid types are disburse and deposit" do
    expect(Payment.valid_types).to eq(["Deposit", "Disburse"])
  end
end
