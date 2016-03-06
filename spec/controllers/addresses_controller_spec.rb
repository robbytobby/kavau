require 'rails_helper'

RSpec.describe AddressesController, type: :controller do
  #NOTE (conditional) Redirects are specified in feature/creditors/redirects_spec.rb
  before(:each){ sign_in create(:admin) }
  
  describe "Get index for creditors" do
    it "assigns all the creditors and renders index" do
      person = create :person
      organization = create :organization
      get :index, type: 'Creditor'
      expect(assigns(:addresses)).to eq([person, organization])
    end

    it "assigns the type" do
      get :index, type: 'Creditor'
      expect(assigns(:type)).to eq('Creditor')
    end

    it "renders index" do
      create :person
      create :organization
      get :index, type: 'Creditor'
      expect(response).to render_template(:index)
    end
  end

  context "csv download" do
    before :each do
      @person = create :person 
      get :download_csv, format: :csv, type: 'Creditor'
    end

    let(:array){ [@person] }
    it_behaves_like "pdf_downloadable"
  end


  describe "flash on project_address show" do
    it "sets flash warning for contacts" do
      @address = create :project_address
      get :show, type: 'ProjectAddress', id: @address
      expect(flash[:warning].first).to include('Geschäftsführer')
    end

    it "sets flash warning for legal informations" do
      @address = create :project_address, :with_contacts
      get :show, type: 'ProjectAddress', id: @address
      ['Sitz', 'Registergericht', 'Register-Nr'].each do |missing|
        expect(flash[:warning].first).to include(missing)
      end
    end

    it "sets flash warning for missing default account" do
      @address = create :project_address, :with_contacts, :with_legals
      get :show, type: 'ProjectAddress', id: @address
      expect(flash[:warning].first).to include('Standard-Konto')
    end

    it "sets no flash warnig if address has contacts and legal_information" do
      @address = create :complete_project_address
      get :show, type: 'ProjectAddress', id: @address
      expect(flash[:warning]).to be_empty
    end
  end

  ['Person', 'Organization', 'ProjectAddress'].each do |type|
    describe "Get show #{type}" do
      before(:each){ @address = create type.underscore.to_sym }
      it "assigns the #{type} as address" do
        get :show, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "renders addresses#show" do
        get :show, type: type, id: @address
        expect(response).to render_template(:show)
      end
    end

    describe "Get new #{type}" do
      it "assigns the a new #{type} as address" do
        get :new, type: type
        expect(assigns(:address)).to be_a(type.constantize)
        expect(assigns(:type)).to eq(type)
      end

      it "renders new" do
        get :new, type: type
        expect(response).to render_template(:new)
      end
    end

    describe "Get edit #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        get :edit, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "renders edit" do
        get :edit, type: type, id: @address
        expect(response).to render_template(:edit)
      end
    end

    describe "Post create #{type}" do
      it "assigns the requested #{type} as address" do 
        post :create, type: type, type.underscore => attributes_for(type.underscore)
        expect(assigns(:address)).to be_a(type.constantize)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        post :create, type: type, type.underscore => attributes_for(type.underscore)
        expect(response.status).to eq 302
      end

      it "renders the new template if it fails" do
        do_not(:save, type.constantize)
        expect{
          post :create, type: type, type.underscore => attributes_for(type.underscore)
        }.not_to change{type.constantize.count}
        expect(response).to render_template(:new)  
      end
    end

    describe "Put update #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(response.status).to eq 302
      end

      it "rerenders the edit template if not successfull" do
        do_not(:save, type.constantize)
        put :update, type: type, id: @address, type.underscore => attributes_for(type.underscore)
        expect(response).to render_template(:edit)
      end
    end

    describe "delete destroy #{type}" do
      before(:each){ @address = create type.underscore.to_sym }

      it "assigns the requested #{type} as address" do 
        delete :destroy, type: type, id: @address
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
      end

      it "is successfull" do
        expect{ 
          delete :destroy, type: type, id: @address
        }.to change{ type.constantize.count }
      end

      it "is not successfull" do
        do_not(:destroy, type.constantize)
        expect{
          delete :destroy, type: type, id: @address
        }.not_to change{type.constantize.count}
      end
    end
  end
end

