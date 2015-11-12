require 'rails_helper'

RSpec.describe BalancesController, type: :controller do
  before(:each){ sign_in create(:accountant) }
  before(:each){ @credit_agreement = create :credit_agreement }
  let(:credit_agreement_params){ { credit_agreement_id: @credit_agreement.id } }
  let(:valid_params){ {:balance => attributes_for(:balance)}.merge(credit_agreement_params) }

  describe "GET #index" do
    it "assigns all balances as @balances" do
      balance = create :balance
      get :index
      expect(assigns(:balances)).to eq([balance])
    end
  end

  describe "GET #new" do
    it "assigns a new balance as @balance" do
      get :new, credit_agreement_params
      expect(assigns(:balance)).to be_a_new(Balance)
    end
  end

  describe "GET #edit" do
    it "assigns the requested balance as @balance" do
      balance = create :balance
      get :edit, {:id => balance.to_param}.merge(credit_agreement_params)
      expect(assigns(:balance)).to eq(balance)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Balance" do
        expect {
          post :create, valid_params
        }.to change(Balance, :count).by(1)
      end

      it "assigns a newly created balance as @balance" do
        post :create, valid_params
        expect(assigns(:balance)).to be_a(Balance)
        expect(assigns(:balance)).to be_persisted
      end

      it "redirects to the credit_agreement" do
        post :create, valid_params
        expect(response).to redirect_to(@credit_agreement)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved balance as @balance" do
        do_not(:save, Balance)
        post :create, valid_params
        expect(assigns(:balance)).to be_a_new(Balance)
      end

      it "re-renders the 'new' template" do
        do_not(:save, Balance)
        post :create, valid_params
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    before(:each){ @balance = create :balance }
    context "with valid params" do
      it "updates the requested balances end_amount" do
        put :update, {:id => @balance.to_param, :balance => {end_amount: 1234}}.merge(credit_agreement_params)
        @balance.reload
        expect(@balance.end_amount).to eq(1234)
      end

      it "assigns the requested balance as @balance" do
        put :update, {:id => @balance.to_param, :balance => {}}.merge(credit_agreement_params)
        expect(assigns(:balance)).to eq(@balance)
      end

      it "redirects to the credit_agreement" do
        put :update, {:id => @balance.to_param, :balance => {}}.merge(credit_agreement_params)
        expect(response).to redirect_to(@credit_agreement)
      end
    end

    context "with invalid params" do
      it "assigns the balance as @balance" do
        do_not(:save, Balance)
        put :update, {:id => @balance.to_param, :balance => {}}.merge(credit_agreement_params)
        expect(assigns(:balance)).to eq(@balance)
      end

      it "re-renders the 'edit' template" do
        do_not(:save, Balance)
        put :update, {:id => @balance.to_param, :balance => {}}.merge(credit_agreement_params)
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each){ @balance = create :balance, :manual }

    it "destroys the requested balance" do
      expect {
        delete :destroy, {:id => @balance.to_param}.merge(credit_agreement_params)
      }.to change(Balance, :count).by(-1)
    end

    it "redirects to the credit_agreement" do
      delete :destroy, {:id => @balance.to_param}.merge(credit_agreement_params)
      expect(response).to redirect_to(@credit_agreement)
    end
  end

end
