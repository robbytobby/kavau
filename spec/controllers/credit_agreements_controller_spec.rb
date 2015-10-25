require 'rails_helper'

['Organization', 'Person'].each do |type|
  RSpec.describe CreditAgreementsController, type: :controller do
    let(:creditor_params) { {type: type, "#{type.underscore}_id": @creditor.id} }
    before(:each){ sign_in create(:accountant) }
    before(:each){@creditor = create type.underscore.to_sym}
    
    describe "GET #index" do
      it "assigns all credit_agreements as @credit_agreements" do
        credit_agreement = create :credit_agreement
        get :index
        expect(assigns(:credit_agreements)).to eq([credit_agreement])
      end
    end

    #describe "GET #show" do
    #  it "assigns the requested credit_agreement as @credit_agreement" do
    #    credit_agreement = CreditAgreement.create! valid_attributes
    #    get :show, {:id => credit_agreement.to_param}, valid_session
    #    expect(assigns(:credit_agreement)).to eq(credit_agreement)
    #  end
    #end

    describe "GET #new for #{type}" do
      it "assigns a new credit_agreement as @credit_agreement" do
        get :new, creditor_params
        expect(assigns(:credit_agreement)).to be_a_new(CreditAgreement)
        expect(assigns(:creditor)).to eq(@creditor)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit for #{type}"  do
      it "assigns the requested credit_agreement as @credit_agreement" do
        credit_agreement = create :credit_agreement, creditor: @creditor
        get :edit, {:id => credit_agreement.to_param}.merge(creditor_params)
        expect(assigns(:credit_agreement)).to eq(credit_agreement)
        expect(assigns(:creditor)).to eq(@creditor)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST #create" do
      before(:each){ @account =  create :project_account }
      let(:valid_params){ {:credit_agreement => 
                                attributes_for(:credit_agreement).
                                merge(account_id: @account.id)}.
                                merge(creditor_params) }

      context "with valid params" do
        it "creates a new CreditAgreement" do
          expect {
            post :create, valid_params
          }.to change(CreditAgreement, :count).by(1)
        end

        it "assigns a newly created credit_agreement as @credit_agreement" do
          post :create, valid_params
          expect(assigns(:credit_agreement)).to be_a(CreditAgreement)
          expect(assigns(:credit_agreement)).to be_persisted
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the creditor" do
          post :create, valid_params
          expect(response).to redirect_to(@creditor)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved credit_agreement as @credit_agreement" do
          do_not(:save, CreditAgreement)
          post :create, valid_params
          expect(assigns(:credit_agreement)).to be_a_new(CreditAgreement)
        end

        it "re-renders the 'new' template" do
          do_not(:save, CreditAgreement)
          post :create, valid_params
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      before(:each){ @credit_agreement =  create :credit_agreement, creditor: @creditor }
      let(:request_params){ {:id => @credit_agreement.to_param, 
                             :credit_agreement => {amount: 20000.00}
                             }.merge(creditor_params) }

                              
      context "with valid params" do

        it "updates the requested credit_agreement" do
          put :update, request_params
          @credit_agreement.reload
          expect(@credit_agreement.amount).to eq(20000.00)
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "assigns the requested credit_agreement as @credit_agreement" do
          put :update, request_params
          expect(assigns(:credit_agreement)).to eq(@credit_agreement)
        end
      end

      context "with invalid params" do
        it "assigns the credit_agreement as @credit_agreement" do
          do_not(:save, CreditAgreement)
          put :update, request_params
          expect(assigns(:credit_agreement)).to eq(@credit_agreement)
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "re-renders the 'edit' template" do
          do_not(:save, CreditAgreement)
          put :update, request_params
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @credit_agreement =  create :credit_agreement, creditor: @creditor }
      it "destroys the requested credit_agreement" do
        expect {
          delete :destroy, {:id => @credit_agreement.to_param}.merge(creditor_params)
        }.to change(CreditAgreement, :count).by(-1)
      end
    end

  end
end
