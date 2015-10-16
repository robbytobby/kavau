require 'rails_helper'

['Organization', 'ProjectAddress'].each do |type|
RSpec.describe ContactsController, type: :controller do
  let(:valid_session) { {} }
  let(:address_params) { {type: type, "#{type.underscore}_id": @address.id} }
  before(:each){ sign_in create(:user) }
  before(:each){@address = create type.underscore.to_sym}

    describe "GET #new" do
      it "assigns a new contact as @contact" do
        get :new, address_params, valid_session
        expect(assigns(:contact)).to be_a_new(Contact)
        expect(assigns(:organization)).to eq(@address)
        expect(assigns(:type)).to eq(type.constantize)
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit" do
      it "assigns the requested contact as @contact" do
        contact = create :contact, organization: @address
        get :edit, {:id => contact.id}.merge(address_params), valid_session
        expect(assigns(:contact)).to eq(contact)
        expect(assigns(:organization)).to eq(@address)
        expect(assigns(:type)).to eq(type.constantize)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Contact" do
          expect {
            post :create, {:contact => attributes_for(:contact)}.merge(address_params), valid_session
          }.to change(Contact, :count).by(1)
        end

        it "assigns a newly created contact as @contact" do
          post :create, {:contact => attributes_for(:contact)}.merge(address_params), valid_session
          expect(assigns(:contact)).to be_a(Contact)
          expect(assigns(:contact)).to be_persisted
          expect(assigns(:organization)).to eq(@address)
          expect(assigns(:type)).to eq(type.constantize)
        end

        it "redirects to the created contact" do
          post :create, {:contact => attributes_for(:contact)}.merge(address_params), valid_session
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved contact as @contact" do
          do_not_save_contacts
          post :create, {:contact => attributes_for(:contact)}.merge(address_params), valid_session
          expect(assigns(:contact)).to be_a_new(Contact)
          expect(assigns(:organization)).to eq(@address)
          expect(assigns(:type)).to eq(type.constantize)
        end

        it "re-renders the 'new' template" do
          do_not_save_contacts
          post :create, {:contact => attributes_for(:contact)}.merge(address_params), valid_session
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      before(:each){ @contact = create(:contact, organization: @address) }
      context "with valid params" do
        it "updates the requested @contact" do
          put :update, {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params), valid_session
          @contact.reload
          expect(@contact.name).to eq('New Name')
        end

        it "assigns the requested contact as @contact" do
          put :update, {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params), valid_session
          expect(assigns(:contact)).to eq(@contact)
          expect(assigns(:organization)).to eq(@address)
          expect(assigns(:type)).to eq(type.constantize)
        end

        it "redirects to the @contact" do
          put :update, {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params), valid_session
          expect(response).to redirect_to(@address)
        end
      end

      context "with invalid params" do
        it "assigns the contact as @contact" do
          do_not_save_contacts
          put :update, {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params), valid_session
          expect(assigns(:contact)).to eq(@contact)
        end

        it "re-renders the 'edit' template" do
          do_not_save_contacts
          put :update, {:id => @contact.to_param, :contact => {name: 'New Name'}}.merge(address_params), valid_session
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @contact = create(:contact, organization: @address) }
      it "destroys the requested contact" do
        expect {
          delete :destroy, {:id => @contact.to_param}.merge(address_params), valid_session
        }.to change(Contact, :count).by(-1)
      end

      it "redirects to the contacts list" do
        delete :destroy, {:id => @contact.to_param}.merge(address_params), valid_session
        expect(response).to redirect_to(@address)
      end
    end
  end

end

def do_not_save_contacts
  allow_any_instance_of(Contact).to receive(:save).and_return(false)
  allow_any_instance_of(Contact).to receive(:errors).and_return(base: 'Failure')
end

