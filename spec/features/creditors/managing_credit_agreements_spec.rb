require 'rails_helper'

RSpec.describe "managing credit aggreements" do
  [:admin, :accountant].each do |role|
    ['Organization', 'Person'].each do |type|
      context "as #{role}" do
        before(:each){ @account = create :project_account, name: 'Account' }
        before(:each){ @creditor = create type.underscore.to_sym }
        before(:each){ login_as create(role) }

        it "I can add a credit agreement to a #{type}" do
          visit model_path(@creditor)
          click_on 'add_credit_agreement'
          expect(current_path).to eq(send("new_#{type.underscore}_credit_agreement_path", @creditor))
          fill_in :credit_agreement_amount, with: '1000'
          fill_in :credit_agreement_interest_rate, with: '1'
          fill_in :credit_agreement_cancellation_period, with:'3'
          fill_in :credit_agreement_number, with: ''
          select '1', from: :credit_agreement_valid_from_3i
          select 'Januar', from: :credit_agreement_valid_from_2i
          select '2016', from: :credit_agreement_valid_from_1i
          select 'Account', from: 'credit_agreement_account_id'
          click_on :submit
          expect(current_path).to eq(model_path(@creditor))
          expect(page).to have_selector('div.alert.alert-notice')
        end

        it "I can cancel adding a credit agreement to a #{type.underscore}" do
          visit model_path(@creditor)
          click_on 'add_credit_agreement'
          click_on :cancel
          expect(current_path).to eq(model_path(@creditor))
        end

        describe "existing credit_agreements" do
          before(:each){ @credit_agreement = create(:credit_agreement, account: @account, creditor: @creditor, valid_from: Date.new(2014,1,1)) }

          it "of a #{type.underscore} are editable" do
            visit model_path(@creditor)
            click_on "edit_credit_agreement_#{@credit_agreement.id}"
            fill_in :credit_agreement_amount, with: '20000'
            select '1', from: :credit_agreement_valid_from_3i
            select 'Januar', from: :credit_agreement_valid_from_2i
            select '2016', from: :credit_agreement_valid_from_1i
            click_on :submit
            expect(current_path).to eq(model_path(@creditor))
            expect(page).to have_selector('div.alert-notice')
          end

          it "of a #{type.underscore} - cancel editing is possible" do
            visit model_path(@creditor)
            click_on "edit_credit_agreement_#{@credit_agreement.id}"
            click_on :cancel
            expect(current_path).to eq(model_path(@creditor))
          end

          it "of a #{type} can be deleted" do
            visit model_path(@creditor)
            click_on "delete_credit_agreement_#{@credit_agreement.id}"
            expect(current_path).to eq(model_path(@creditor))
            expect(page).to have_selector('div.alert-notice')
          end
        end
        
      end
    end
  end

  def model_path(creditor)
    send("#{creditor.type.underscore}_path", creditor)
  end
end
