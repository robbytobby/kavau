require 'rails_helper'

RSpec.describe ProjectAddress do
  describe "missing_legals" do
    context "everything is set up" do
      before :each do
        @project_address = create :project_address, :with_legals
      end

      it "legal_information_missing? is false" do
        expect(@project_address.legal_information_missing?).to be_falsy
      end

      it "missing legals is emtpy" do
        expect(@project_address.missing_legals).to be_empty
      end
    end

    context "without legal information" do
      before :each do
        @project_address = create :project_address
      end

      it "legal_information_missing? is true" do
        expect(@project_address.legal_information_missing?).to be_truthy
      end

      ["based_in", "register_court", "registration_number"].each do |key|
        it "#{key} is missing" do
          expect(@project_address.missing_legals).to include(key)
        end
      end
    end
  end
end
