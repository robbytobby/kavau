require 'rails_helper'

RSpec.describe ProjectAddressPolicy do
  subject { ProjectAddressPolicy.new(user, address) }
  let(:address) { FactoryGirl.create(:project_address) }

  it_behaves_like "standard_address"
end

