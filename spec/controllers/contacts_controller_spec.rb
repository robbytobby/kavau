require 'rails_helper'

['Organization', 'ProjectAddress'].each do |type|
RSpec.describe ContactsController, type: :controller do
  let(:address_params) { {type: type, "#{type.underscore}_id": @address.id} }
  before(:each){ sign_in create(:accountant) }
  before(:each){@address = create type.underscore.to_sym}

    describe "GET #new" do
      it "assigns a new contact as @contact" do
        get :new, params: address_params
        expect(assigns(:contact)).to be_a_new(Contact)
        expect(assigns(:institution)).to eq(@address)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit" do
      it "assigns the requested contact as @contact" do
        contact = create :contact, institution: @address
        get :edit, params: {:id => contact.id}.merge(address_params)
        expect(assigns(:contact)).to eq(contact)
        expect(assigns(:institution)).to eq(@address)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Contact" do
          expect {
            post :create, params: {:contact => attributes_for(:contact)}.merge(address_params)
          }.to change(Contact, :count).by(1)
        end

        it "assigns a newly created contact as @contact" do
          post :create, params: {:contact => attributes_for(:contact)}.merge(address_params)
          expect(assigns(:contact)).to be_a(Contact)
          expect(assigns(:contact)).to be_persisted
          expect(assigns(:institution)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the contacts address" do
          post :create, params: {:contact => attributes_for(:contact)}.merge(address_params)
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved contact as @contact" do
          do_not(:save, Contact)
          post :create, params: {:contact => attributes_for(:contact)}.merge(address_params)
          expect(assigns(:contact)).to be_a_new(Contact)
          expect(assigns(:institution)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "re-renders the 'new' template" do
          do_not(:save, Contact)
          post :create, params: {:contact => attributes_for(:contact)}.merge(address_params)
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      before(:each){ @contact = create(:contact, institution: @address) }
      context "with valid params" do
        it "updates the requested @contact" do
          put :update, params: {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params)
          @contact.reload
          expect(@contact.name).to eq('New Name')
        end

        it "assigns the requested contact as @contact" do
          put :update, params: {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params)
          expect(assigns(:contact)).to eq(@contact)
          expect(assigns(:institution)).to eq(@address)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the @contact" do
          put :update, params: {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params)
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns the contact as @contact" do
          do_not(:save, Contact)
          put :update, params: {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params)
          expect(assigns(:contact)).to eq(@contact)
        end

        it "re-renders the 'edit' template" do
          do_not(:save, Contact)
          put :update, params: {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params)
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @contact = create(:contact, institution: @address) }
      it "destroys the requested contact" do
        expect {
          delete :destroy, params: {:id => @contact.to_param}.merge(address_params)
        }.to change(Contact, :count).by(-1)
      end

      it "redirects to the contacts list" do
        delete :destroy, params: {:id => @contact.to_param}.merge(address_params)
        expect(response).to redirect_to(@address)
      end
    end
  end

end


