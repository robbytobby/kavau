require 'rails_helper'

RSpec.describe ProjectController, type: :controller do
  before(:all){ Fund.delete_all }
  before(:each){ sign_in create(:user) }

  describe "GET show" do
    it "assigns the funds as @funds" do
      fund = create :fund
      get :show
      expect(assigns(:funds)).to eq [fund]
    end

    it "assigns all accounts as @accounts" do
      Account.delete_all
      account = create :project_account
      get :show
      expect(assigns(:accounts)).to eq [account]
    end

    it "assigns all the project_addresses and renders index" do
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
      it "sets flash warning if therere is no project society addresses" do
        create :project_address, legal_form: 'limited'
        get :show
        expect(flash[:warning]).to include('Eine Adresse für den Hausverein muß angelegt werden')
      end

      it "sets flash warning if therere is no project limited addresses" do
        create :project_address, legal_form: 'registered_society'
        get :show
        expect(flash[:warning]).to include('Eine Adresse für die Hausbesitz-Gmbh muß angelegt werden')
      end

      it "sets flash warning for contacts" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, legal_form: 'limited'
        get :show
        expect(flash[:warning].first).to include('Geschäftsführer')
      end

      it "sets flash warning for legal informations" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, :with_contacts
        get :show
        ['Sitz', 'Registergericht', 'Register-Nr'].each do |missing|
          expect(flash[:warning].first).to include(missing)
        end
      end

      it "sets flash warning for missing default_account" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :project_address, :with_contacts, :with_legals
        get :show
        expect(flash[:warning].first).to include('Standard-Konto')
      end

      it "sets no flash warnig if address has contacts and legal_information" do
        create :complete_project_address, legal_form: 'registered_society'
        address = create :complete_project_address
        get :show
        expect(flash[:warning]).to be_empty
      end
    end
  end

end

