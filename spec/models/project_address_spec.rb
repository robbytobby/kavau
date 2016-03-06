require 'rails_helper'

RSpec.describe ProjectAddress do
  describe "default_address" do
    it "is the first registered_society" do
      address = create :project_address, legal_form: 'registered_society'
      expect(ProjectAddress.default).to eq(address)
    end

    it "is the first society" do
      address = create :project_address, legal_form: 'society'
      expect(ProjectAddress.default).to eq(address)
    end

    it "is the registered_society if both a registered society and a non registered_society are present" do
      create :project_address, legal_form: 'society'
      address = create :project_address, legal_form: 'registered_society'
      expect(ProjectAddress.default).to eq(address)
    end
  end

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
      ['limited', 'registered_society'].each do |form|
        context "legal form is #{form}" do
          before :each do
            @project_address = create :project_address, legal_form: form
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

      context "legal form is society" do
        before :each do
          @project_address = create :project_address, legal_form: 'society'
        end

        it "legal_information_missing? is false" do
          expect(@project_address.legal_information_missing?).to be_falsy
        end
        
        it "missing_legals is empty" do
          expect(@project_address.missing_legals).to be_empty
        end
      end
    end
  end
end
