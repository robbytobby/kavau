require 'rails_helper'

RSpec.describe PersonPolicy do
  subject { PersonPolicy.new(user, address) }
  let(:address) { FactoryGirl.create(:person) }

  it_behaves_like "standard_address"
end

