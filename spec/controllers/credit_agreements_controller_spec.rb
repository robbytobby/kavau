require 'rails_helper'

['Organization', 'Person'].each do |type|
  RSpec.describe CreditAgreementsController, type: :controller do
    let(:creditor_params) { {type: type, "#{type.underscore}_id": @creditor.id} }
    before(:each){ 
      sign_in create(:accountant) 
      @creditor = create type.underscore.to_sym
      dont_validate_fund_for CreditAgreement
    }
    
    describe "GET #index" do
      it "assigns all credit_agreements as @credit_agreements" do
        credit_agreement = create :credit_agreement
        get :index
        expect(assigns(:credit_agreements)).to eq([credit_agreement])
      end
    end

    context "xlsx download" do
      before :each do
        @credit_agreement = create :credit_agreement 
        get :index, format: :xlsx
      end

      let(:array){ [@credit_agreement] }
      let(:collection_name){ :credit_agreements }
      let(:filename){ 'Kreditverträge' }
      it_behaves_like "xlsx_downloadable"
    end

    describe "GET #show" do
      it "assigns the requested credit_agreement as @credit_agreement" do
        credit_agreement = create :credit_agreement
        get :show, params: {:id => credit_agreement.to_param}
        expect(assigns(:credit_agreement)).to eq(credit_agreement)
      end
    end

    describe "GET #new for #{type}" do
      it "does not work if there are no accounts for the project" do
        Account.delete_all
        request.env["HTTP_REFERER"] = '/back'
        get :new, params: creditor_params
        expect(response).to redirect_to '/back'
      end

      it "assigns a new credit_agreement as @credit_agreement" do
        create :project_account
        get :new, params: creditor_params
        expect(assigns(:credit_agreement)).to be_a_new(CreditAgreement)
        expect(assigns(:creditor)).to eq(@creditor)
        expect(assigns(:type)).to eq(type)
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit for #{type}"  do
      it "assigns the requested credit_agreement as @credit_agreement" do
        credit_agreement = create :credit_agreement, creditor: @creditor
        get :edit, params: {:id => credit_agreement.to_param}.merge(creditor_params)
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
            post :create, params: valid_params
          }.to change(CreditAgreement, :count).by(1)
        end

        it "assigns a newly created credit_agreement as @credit_agreement" do
          post :create, params: valid_params
          expect(assigns(:credit_agreement)).to be_a(CreditAgreement)
          expect(assigns(:credit_agreement)).to be_persisted
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "redirects to the creditor" do
          post :create, params: valid_params
          expect(response).to redirect_to(@creditor)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved credit_agreement as @credit_agreement" do
          do_not(:save, CreditAgreement)
          post :create, params: valid_params
          expect(assigns(:credit_agreement)).to be_a_new(CreditAgreement)
        end

        it "re-renders the 'new' template" do
          do_not(:save, CreditAgreement)
          post :create, params: valid_params
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
          put :update, params: request_params
          @credit_agreement.reload
          expect(@credit_agreement.amount).to eq(20000.00)
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "assigns the requested credit_agreement as @credit_agreement" do
          put :update, params: request_params
          expect(assigns(:credit_agreement)).to eq(@credit_agreement)
        end
      end

      context "with invalid params" do
        it "assigns the credit_agreement as @credit_agreement" do
          do_not(:save, CreditAgreement)
          put :update, params: request_params
          expect(assigns(:credit_agreement)).to eq(@credit_agreement)
          expect(assigns(:creditor)).to eq(@creditor)
          expect(assigns(:type)).to eq(type)
        end

        it "re-renders the 'edit' template" do
          do_not(:save, CreditAgreement)
          put :update, params: request_params
          expect(response).to render_template("edit")
        end

        it "redirect to the show page if terminat_date is the problem" do
          request_params = { :id => @credit_agreement.to_param, 
                             :credit_agreement => {terminated_at: Date.today}
                           }.merge(creditor_params)
          do_not(:save, CreditAgreement, :terminated_at)
          put :update, params: request_params
          expect(response).to render_template("show")
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @credit_agreement =  create :credit_agreement, creditor: @creditor }
      it "destroys the requested credit_agreement" do
        expect {
          delete :destroy, params: {:id => @credit_agreement.to_param}.merge(creditor_params)
        }.to change(CreditAgreement, :count).by(-1)
      end
    end

    describe "GET create_yearly_balances" do
      it "triggers balance creation" do
        expect(CreditAgreement).to receive(:create_yearly_balances).with(no_args)
        get :create_yearly_balances
      end

      it "redirects to root" do
        get :create_yearly_balances
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
