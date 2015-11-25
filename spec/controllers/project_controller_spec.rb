require 'rails_helper'

RSpec.describe ProjectController, type: :controller do
  before(:each){ sign_in create(:user) }

  describe "GET show" do
    it "assigns all the creditors and renders index" do
      address = create :project_address
      get :show
      expect(response).to render_template(:show)
    end

    it "renders project#show" do
      address = create :project_address
      get :show
      expect(assigns(:addresses)).to eq([address])

    end

    describe "flash warning" do
      it "sets flash warning for contacts" do
        address = create :project_address
        get :show
        expect(flash[:warning].first).to include('Geschäftsführer')
      end

      it "sets flash warning for legal informations" do
        address = create :project_address, :with_contacts
        get :show
        ['Sitz', 'Registergericht', 'Register-Nr', 'UST-Id-Nr', 'Steuernummer'].each do |missing|
          expect(flash[:warning].first).to include(missing)
        end
      end

      it "sets flash warning for missing default_account" do
        address = create :project_address, :with_contacts, :with_legals
        get :show
        expect(flash[:warning].first).to include('Standard-Konto')
      end

      it "sets no flash warnig if address has contacts and legal_information" do
        address = create :complete_project_address
        get :show
        expect(flash[:warning]).to be_empty
      end
    end
  end
end

