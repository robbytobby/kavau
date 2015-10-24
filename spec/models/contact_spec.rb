require 'rails_helper'

RSpec.describe Contact do
  it "list_actions are rendered_with the same partial" do
    address = create :contact 
    expect(address.list_action_partial_path).to eq('addresses/contact_list_actions')
  end
end
