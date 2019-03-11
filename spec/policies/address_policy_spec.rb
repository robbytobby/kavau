require 'rails_helper'

RSpec.describe AddressPolicy do
  subject { AddressPolicy.new(user, address) }
  let(:address) { FactoryBot.create(:address) }

  it_behaves_like "address_policy"
end
