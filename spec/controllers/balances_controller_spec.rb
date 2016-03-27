require 'rails_helper'

RSpec.describe BalancesController, type: :controller do
  before(:each){ sign_in create(:accountant) }
  before(:each){ @credit_agreement = create :credit_agreement }
  let(:credit_agreement_params){ { credit_agreement_id: @credit_agreement.id } }

  ['AutoBalance', 'ManualBalance', 'TerminationBalance'].each do |balance_type|
    context "#{balance_type}" do
      let(:key){ balance_type.underscore.to_sym }
      before(:each){ @balance = create key }

      describe "GET #index" do
        it "assigns all balances as @balances" do
          get :index
          expect(assigns(:balances)).to eq([@balance])
        end
      end

      context "xlsx download" do
        let(:array){ [@balance] }
        before(:each){ get :index, format: :xlsx}

        let(:array){ [@balance] }
        let(:collection_name){:balances}
        let(:filename){ 'Salden' }
        it_behaves_like "xlsx_downloadable"
      end

      describe "GET #show format: pdf" do
        before(:each){ allow_any_instance_of(Balance).to receive(:pdf).and_return(true) }

        it "assigns the requested balance as @balance" do
          get :show, id: @balance.id, format: 'pdf'
          expect(assigns(:balance)).to eq(@balance)
        end

        it "sends the balances pdf" do
          pending 'get this test working - complains about missing template'
          get :show, id: @balance.id, format: 'pdf'
          rendered_pdf = BalancePdf.new(@balance).render
          expect(response.body).to eq(rendered_pdf)
        end
      end
    end
  end

  ['AutoBalance', 'ManualBalance'].each do |balance_type|
    context "#{balance_type}" do
      let(:key){ balance_type.underscore.to_sym }
      let(:valid_params){ { key => attributes_for(key), type: balance_type}.merge(credit_agreement_params) }
      #describe "GET #new" do
      #  it "assigns a new balance as @balance" do
      #    get :new, credit_agreement_params.merge(type: balance_type)
      #    expect(assigns(:balance)).to be_a_new(Balance)
      #  end
      #end

      describe "GET #edit" do
        it "assigns the requested balance as @balance" do
          balance = create balance_type.underscore
          get :edit, {:id => balance.to_param, type: balance_type}.merge(credit_agreement_params)
          expect(assigns(:balance)).to eq(balance)
        end
      end

      describe "PUT #update" do
        before(:each){ @balance = create balance_type.underscore }
        let(:valid_params){ 
          { id: @balance.id, key => attributes_for(key), type: balance_type}.
          merge(credit_agreement_params) 
        }

        context "with valid params" do
          it "updates the requested balances end_amount" do
            put :update, valid_params.deep_merge(key => { end_amount: 1234 })
            @balance = Balance.find(@balance.id)
            expect(@balance.end_amount).to eq(1234)
          end

          it "assigns the requested balance as @balance" do
            put :update, valid_params
            expect(assigns(:balance)).to eq(@balance)
          end

          it "the balance becomes a ManualBalance if end_amount is changed" do
            put :update, valid_params.deep_merge(key => { end_amount: 1234 })
            expect(assigns(:balance)).to be_a(ManualBalance)
          end

          it "redirects to the credit_agreement" do
            put :update, valid_params
            expect(response).to redirect_to(@credit_agreement)
          end
        end

        context "with invalid params" do
          it "assigns the balance as @balance" do
            do_not(:save, Balance)
            put :update, valid_params
            expect(assigns(:balance)).to eq(@balance)
          end

          it "re-renders the 'edit' template" do
            do_not(:save, Balance)
            put :update, valid_params
            expect(response).to render_template("edit")
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "ManualBalance" do
      before(:each){ @balance = create :manual_balance }
      let(:valid_params){ { type: 'ManualBalance', id: @balance.to_param }.merge(credit_agreement_params) }

      it "destroys the requested balance" do
        expect {
          delete :destroy, valid_params
        }.to change(Balance, :count).by(-1)
      end

      it "redirects to the credit_agreement" do
        delete :destroy, valid_params
        expect(response).to redirect_to(@credit_agreement)
      end
    end
  end
end
