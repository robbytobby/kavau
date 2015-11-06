require 'rails_helper'

RSpec.describe "managing payments" do
  include ActionView::Helpers::NumberHelper
  [:accountant, :admin].each do |type|
    [:deposit, :disburse].each do |payment_type|
      context "as #{type}" do
        before :each do
          login_as create(type)
          @credit_agreement = create :credit_agreement
          @payment = create payment_type, credit_agreement: @credit_agreement
        end

        it "the credit_agreement page shows the associated #{payment_type.to_s.pluralize}" do
          visit credit_agreement_path(@credit_agreement)
          expect(page).to have_css("tr##{payment_type}_#{@payment.id}")
        end

        it "I can edit a #{payment_type}" do
          visit credit_agreement_path(@credit_agreement)
          click_on "edit_payment_#{@payment.id}"
          expect(current_path).to eq edit_credit_agreement_payment_path(@credit_agreement, @payment)
          fill_in :payment_amount, with: 222
          click_on :submit
          expect(current_path).to eq(credit_agreement_path(@credit_agreement))
          expect(page).to have_content(number_to_currency(222))
        end

        it "I can create a incoming payment", js: true do
          #pending "debug js testing"
          visit credit_agreement_path(@credit_agreement)
          fill_in :payment_amount, with: 500
          select 'Einzahlung', from: :payment_type
          click_on :submit
          # TODO: works put capybara does not get it
          expect(page).to have_content(number_to_currency(500))
        end

        it "I can destroy a #{payment_type}" do
          visit credit_agreement_path(@credit_agreement)
          click_on "delete_payment_#{@payment.id}"
          expect(current_path).to eq(credit_agreement_path(@credit_agreement))
          expect(page).not_to have_css("tr##{payment_type}_#{@payment.id}")
        end
      end
    end
  end

  context "as unpriviledged user" do
    [:deposit, :disburse].each do |payment_type|
      before :each do
        login_as create(:user)
        @credit_agreement = create :credit_agreement
        @payment = create payment_type, credit_agreement: @credit_agreement
      end

      it "I can't even show the credit_agreement" do
        visit credit_agreement_path(@credit_agreement)
        expect(current_path).to eq('/')
      end
    end
  end
end

