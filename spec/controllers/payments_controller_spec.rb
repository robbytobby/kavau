require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  before :each do
    sign_in create(:accountant) 
    @credit_agreement = create :credit_agreement
  end

  let(:credit_agreement_params){ { credit_agreement_id: @credit_agreement.id } }

  [:deposit, :disburse].each do |payment_type|
    describe "GET #index" do
      before :each do
        @deposit = create :deposit
        @disburse = create :disburse
      end

      it "assigns the payments as @payments" do
        get :index
        expect(assigns(:payments)).to include(@deposit, @disburse)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "xlsx download" do
      before :each do
        @payment = create :deposit
        get :index, format: :xlsx
      end

      let(:array){ [@payment] }
      let(:collection_name){ :payments }
      let(:filename){ 'Zahlungen' }
      it_behaves_like "xlsx_downloadable"
    end

    describe "GET #show format: pdf" do
      before :each do
        project = create :complete_project_address 
        @credit_agreement = create :credit_agreement, account: project.accounts.first
        @payment = create payment_type, credit_agreement: @credit_agreement
      end

      context "without the corresponing template" do
        it "redirects to the letters" do
          get :show, params: { id: @payment.id }, format: 'pdf'
          expect(response).to redirect_to(letters_path)
        end
      end

      context "with an exisiting template" do
        before(:each){ create "#{@payment.class.name.underscore}_letter" }
        it "assigns the requested payment as @payment" do
          get :show, params: { id: @payment.id }, format: 'pdf'
          expect(assigns(:payment)).to eq(@payment)
        end

        it "assigns the right template" do
          get :show, params: { id: @payment.id }, format: 'pdf'
          expect(assigns(:template)).to be_a("#{@payment.class}Letter".constantize)
        end

        it "saves the pdf" do
          get :show, params: { id: @payment.id }, format: 'pdf'
          expect(@payment.reload.pdf).to be_persisted
        end
      end
    end

    describe "POST #create" do
      let(:valid_params){ { payment: attributes_for(payment_type) } }

      context "with valid params" do
        before(:each){ allow_any_instance_of(Disburse).to receive(:amount_fits).and_return(true) }

        it 'creates a new Payment' do
          expect {
            post :create, params: valid_params.merge(credit_agreement_params).merge(format: :js)
          }.to change(Payment, :count).by(1)
        end

        it 'assign the newly created payment as @payment' do
          post :create, params: valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(assigns(:payment)).to be_a(Payment)
          expect(assigns(:payment)).to be_persisted
        end

        it 'renders new (js)' do
          post :create, params: valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(response).to render_template(:new)
        end
      end

      context "with invalid params" do
        it "does not create a new Payment" do
          do_not(:save, Payment)
          expect {
            post :create, params: valid_params.merge(credit_agreement_params).merge(format: :js)
          }.not_to change(Payment, :count)
        end

        it 'renders new (js)' do
          do_not(:save, Payment)
          post :create, params: valid_params.merge(credit_agreement_params).merge(format: :js)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "GET #edit" do
      before(:each){ @payment = create payment_type }

      it "assigns the requested payment as @payment" do
        get :edit, params: {id: @payment.id}.merge(credit_agreement_params)
        expect(assigns(:payment)).to eq(@payment)
      end

      it "renders edit" do
        get :edit, params: {id: @payment.id}.merge(credit_agreement_params)
        expect(response).to render_template(:edit)
      end
    end

    describe "PUT #update" do
      before(:each){ @payment = create payment_type }
      let(:update_params){ {id: @payment.id, payment: {amount: 123}}.merge(credit_agreement_params) }

      context "with valid params" do
        it "updates the requested payment" do
          put :update, params: update_params
          @payment.reload
          expect(@payment.amount).to eq(123)
        end

        it "assigns the requested payment as @payment" do
          put :update, params: update_params
          expect(assigns(:payment)).to eq(@payment)
        end

        it "changes the payments class if necessary" do
          new_type = payment_type == :deposit ? 'Disburse' : 'Deposit'
          put :update, params: update_params.deep_merge(payment: {type: new_type})
          expect(assigns(:payment)).to be_a(new_type.constantize)
        end

        it "redirects to the associated credit_agreement" do
          put :update, params: update_params
          expect(response).to redirect_to(@payment.credit_agreement)
        end
      end

      context "with invalid params" do
        it "assigns the requested payment as @payment" do
          do_not(:save, Payment)
          put :update, params: update_params
          expect(assigns(:payment)).to eq(@payment)
        end

        it "re-renders edit" do
          do_not(:save, Payment)
          put :update, params: update_params
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE #destroy" do
      before(:each){ @payment = create payment_type }

      it "destroys the requested payment" do
        expect {
          delete :destroy, params: {id: @payment.to_param}.merge(credit_agreement_params)
        }.to change(Payment, :count).by(-1)
      end

      it "redirects to the associated credit_agreement" do
        delete :destroy, params: {id: @payment.to_param}.merge(credit_agreement_params)
        expect(response).to redirect_to(@payment.credit_agreement)
      end
    end
  end
end
