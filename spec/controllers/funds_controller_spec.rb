require 'rails_helper'

RSpec.describe FundsController, type: :controller do

  let(:valid_attributes) {
    attributes_for :fund
  }

  let(:invalid_attributes) {
    attributes_for :fund, interest_rate: nil
  }

  before(:each){ sign_in create(:accountant) }

  describe "GET #new" do
    it "assigns a new fund as @fund" do
      get :new
      expect(assigns(:fund)).to be_a_new(Fund)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns the requested fund as @fund" do
      fund = create :fund
      get :edit, {:id => fund.to_param}
      expect(assigns(:fund)).to eq(fund)
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Fund" do
        expect {
          post :create, {:fund => valid_attributes}
        }.to change(Fund, :count).by(1)
      end

      it "assigns a newly created fund as @fund" do
        post :create, {:fund => valid_attributes}
        expect(assigns(:fund)).to be_a(Fund)
        expect(assigns(:fund)).to be_persisted
      end

      it "redirects to the project index" do
        post :create, {:fund => valid_attributes}
        expect(response).to redirect_to project_path
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved fund as @fund" do
        post :create, {:fund => invalid_attributes}
        expect(assigns(:fund)).to be_a_new(Fund)
      end

      it "re-renders the 'new' template" do
        post :create, {:fund => invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    before(:each){ @fund = create(:fund) }

    context "with valid params" do
      let(:new_attributes) {
        { interest_rate: 2.3 }
      }

      it "updates the requested fund" do
        put :update, {:id => @fund.to_param, :fund => new_attributes}
        @fund.reload
        expect(@fund.interest_rate).to eq 2.3
      end

      it "assigns the requested fund as @fund" do
        put :update, {:id => @fund.to_param, :fund => new_attributes}
        expect(assigns(:fund)).to eq(@fund)
      end

      it "redirects to the project index" do
        put :update, {:id => @fund.to_param, :fund => new_attributes}
        expect(response).to redirect_to project_path
      end
    end

    context "with invalid params" do
      it "assigns the fund as @fund" do
        put :update, {:id => @fund.to_param, :fund => invalid_attributes}
        expect(assigns(:fund)).to eq(@fund)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => @fund.to_param, :fund => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each){ @fund = create(:fund) }

    it "destroys the requested fund" do
      expect {
        delete :destroy, {:id => @fund.to_param}
      }.to change(Fund, :count).by(-1)
    end

    it "redirects to the project index" do
      delete :destroy, {:id => @fund.to_param}
      expect(response).to redirect_to project_path
    end
  end

end
