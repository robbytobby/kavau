require 'rails_helper'

['Organization', 'ProjectAddress', 'Person'].each do |type|
  RSpec.describe AccountsController, type: :controller do
    let(:address_params) { {type: type, "#{type.underscore}_id": @address.id} }
    before(:each){ sign_in create(:accountant) }
    before(:each){@address = create type.underscore.to_sym}

    describe "GET #new" do
      it "assigns a new account as @account" do
        get :new, params: address_params
        expect(assigns(:account)).to be_a_new(Account)
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit" do
      it "assigns the requested account as @account" do
        account = create :account, address: @address
        get :edit, params: {:id => account.to_param}.merge(address_params)
        expect(assigns(:account)).to eq(account)
        expect(assigns(:address)).to eq(@address)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Account" do
          expect {
            post :create, params: {:account => attributes_for(:account)}.merge(address_params)
          }.to change(Account, :count).by(1)
        end

        it "assigns a newly created account as @account" do
          post :create, params: {:account => attributes_for(:account)}.merge(address_params)
          expect(assigns(:account)).to be_a(Account)
          expect(assigns(:account)).to be_persisted
          expect(assigns(:address)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the accounts address" do
          post :create, params: {:account => attributes_for(:account)}.merge(address_params)
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved account as @account" do
          do_not(:save, Account)
          post :create, params: {:account => attributes_for(:account)}.merge(address_params)
          expect(assigns(:account)).to be_a_new(Account)
          expect(assigns(:address)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "re-renders the 'new' template" do
          do_not(:save, Account)
          post :create, params: {:account => attributes_for(:account)}.merge(address_params)
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      before(:each){ @account = create(:account, address: @address) }
      context "with valid params" do
        it "updates the requested account" do
          put :update, params: {:id => @account.to_param, :account => {name: 'New Name'}}.merge(address_params)
          @account.reload
          expect(@account.name).to eq('New Name')
        end

        it "assigns the requested account as @account" do
          put :update, params: {:id => @account.to_param, :account => {name: 'New Name'}}.merge(address_params)
          expect(assigns(:account)).to eq(@account)
          expect(assigns(:address)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the accounts address" do
          put :update, params: {:id => @account.to_param, :account => {name: 'New Name'}}.merge(address_params)
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns the account as @account" do
          do_not(:save, Account)
          put :update, params: {:id => @account.to_param, :account => {name: 'New Name'}}.merge(address_params)
          expect(assigns(:account)).to eq(@account)
        end

        it "re-renders the 'edit' template" do
          do_not(:save, Account)
          put :update, params: {:id => @account.to_param, :account => {name: 'New Name'}}.merge(address_params)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @account = create(:account, address: @address) }

      it "destroys the requested account" do
        expect {
          delete :destroy, params: {:id => @account.to_param}.merge(address_params)
        }.to change(Account, :count).by(-1)
      end

      it "redirects to the accounts list" do
        delete :destroy, params: {:id => @account.to_param}.merge(address_params)
        expect(response).to redirect_to(@address)
      end
    end

  end
end
