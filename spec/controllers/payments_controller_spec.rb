require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  before :each do
    sign_in create(:accountant) 
    @credit_agreement = create :credit_agreement
  end

  let(:credit_agreement_params){ { credit_agreement_id: @credit_agreement.id } }

  [:deposit, :disburse].each do |payment_type|
    describe "POST #create" do
      let(:valid_params){ { payment: attributes_for(payment_type) } }

      context "with valid params" do
        it 'creates a new Payment' do
          expect {
            post :create, valid_params.merge(credit_agreement_params).merge(format: :js)
          }.to change(Payment, :count).by(1)
        end

        it 'assign the newly created payment as @payment' do
          post :create, valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(assigns(:payment)).to be_a(Payment)
          expect(assigns(:payment)).to be_persisted
        end

        it 'renders new (js)' do
          post :create, valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(response).to render_template(:new)
        end
      end

      context "with invalid params" do
        it "does not create a new Payment" do
          do_not(:save, Payment)
          expect {
            post :create, valid_params.merge(credit_agreement_params).merge(format: :js)
          }.not_to change(Payment, :count)
        end

        it 'renders new (js)' do
          do_not(:save, Payment)
          post :create, valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "GET #edit" do
      before(:each){ @payment = create payment_type }

      it "assigns the requested payment as @payment" do
        get :edit, {id: @payment.id}.merge(credit_agreement_params)
        expect(assigns(:payment)).to eq(@payment)
      end

      it "renders edit" do
        get :edit, {id: @payment.id}.merge(credit_agreement_params)
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT #update" do
      before(:each){ @payment = create payment_type }
      let(:update_params){ {id: @payment.id, payment: {amount: 123}}.merge(credit_agreement_params) }

      context "with valid params" do
        it "updates the requested payment" do
          put :update, update_params
          @payment.reload
          expect(@payment.amount).to eq(123)
        end

        it "assigns the requested payment as @payment" do
          put :update, update_params
          expect(assigns(:payment)).to eq(@payment)
        end

        it "redirects to the associated credit_agreement" do
          put :update, update_params
          expect(response).to redirect_to(@payment.credit_agreement)
        end
      end

      context "with invalid params" do
        it "assigns the requested payment as @payment" do
          do_not(:save, Payment)
          put :update, update_params
          expect(assigns(:payment)).to eq(@payment)
        end

        it "re-renders edit" do
          do_not(:save, Payment)
          put :update, update_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @payment = create payment_type }

      it "destroys the requested payment" do
        expect {
          delete :destroy, {id: @payment.to_param}.merge(credit_agreement_params)
        }.to change(Payment, :count).by(-1)
      end

      it "redirects to the associated credit_agreement" do
        delete :destroy, {id: @payment.to_param}.merge(credit_agreement_params)
        expect(response).to redirect_to(@payment.credit_agreement)
      end
    end
  end
end
