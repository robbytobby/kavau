require 'rails_helper'

RSpec.describe OrganizationPolicy do
  subject { OrganizationPolicy.new(user, address) }
  let(:address) { FactoryGirl.create(:organization) }

  it_behaves_like "standard_address"
end

