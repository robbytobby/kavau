require 'rails_helper'

RSpec.describe ContactPolicy do
  subject { ContactPolicy.new(user, address) }
  let(:address) { FactoryGirl.create(:contact) }

  it_behaves_like "standard_address"
end

