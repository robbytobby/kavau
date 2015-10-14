require 'rails_helper'

RSpec.describe "adding contacts to addresses" do
  it "is possible to add a contact to a project_address" do
    @address = create :project_address
    visit project_address_path(@address)
    click_on 'add_contact'
    expect(current_path).to eq(new_contact_path)
  end
end

