require 'rails_helper'

RSpec.describe Address do
  [:contact, :organization, :person, :project_address].each do |type|
    it "knows, if it is a #{type}" do
      address = create type
      expect(address.send("#{type}?")).to be_truthy
    end

    ([:contact, :organization, :person, :project_address] - [type]).each do |other_type|
      it "knows if it is not a #{other_type}" do
        address = create type
        expect(address.send("#{other_type}?")).to be_falsy
      end
    end
  end

  [:person, :organization].each do |type|
    it "knows, if it is a creditor" do
      address = create type
      expect(address).to be_creditor
    end
  end

  [:contact, :project_address].each do |type|
    it "knows, if it is no creditor" do
      address = create type
      expect(address).not_to be_creditor
    end
  end

  [:contact, :organization, :person, :project_address].each do |type|
    it "collections of type #{type} are all rendered with the same partial" do
      address = create type
      expect(address.to_partial_path).to eq('addresses/address')
    end
  end

  [:organization, :person, :project_address].each do |type|
    it "list_actions of type #{type} are rendered_with the same partial" do
      address = create type
      expect(address.list_action_partial_path).to eq('addresses/list_actions')
    end
  end


end

