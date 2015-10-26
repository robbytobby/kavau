require 'rails_helper'

RSpec.describe "credit agreements index" do
  include ActionView::Helpers::NumberHelper
  context "as unpriviledged user" do
    before(:each){ login_as create(:user) }

    it "shows the credit agreements index" do
      visit "/"
      click_on 'credit_agreements_index'
      expect(current_path).to eq(credit_agreements_path)
    end

    it "shows credits without creditor name and without edit and delete links"  do
      @credit_agreement = create :credit_agreement
      visit credit_agreements_path
      expect(page).to have_content(number_to_currency(@credit_agreement.amount))
      expect(page).to have_content(@credit_agreement.account.name)
      expect(page).to have_content(number_to_percentage(@credit_agreement.interest_rate))
      expect(page).to_not have_content(@credit_agreement.creditor.name)
      expect(page).to_not have_content(@credit_agreement.creditor.first_name)
      expect(page).to_not have_css("a#edit_credit_agreement_#{@credit_agreement.id}")
      expect(page).to_not have_css("a#delete_credit_agreement_#{@credit_agreement.id}")
    end
  end

  [:accountant, :admin].each do |type|
    context "as #{type}" do
      before(:each){ login_as create(type) }

      it "shows the credit agreements index" do
        visit "/"
        click_on 'credit_agreements_index'
        expect(current_path).to eq(credit_agreements_path)
      end

      it "shows credits with creditor and links"  do
        @credit_agreement = create :credit_agreement
        visit credit_agreements_path
        expect(page).to have_content(number_to_currency(@credit_agreement.amount))
        expect(page).to have_content(@credit_agreement.account.name)
        expect(page).to have_content(number_to_percentage(@credit_agreement.interest_rate))
        expect(page).to have_content(@credit_agreement.creditor.name)
        expect(page).to have_content(@credit_agreement.creditor.first_name)
        expect(page).to have_css("a#edit_credit_agreement_#{@credit_agreement.id}")
        expect(page).to have_css("a#delete_credit_agreement_#{@credit_agreement.id}")
      end
    end
  end

  describe "it is searchable" do
    before(:each){ login_as create(:accountant) }

    it "by id" do
      c1 = create :credit_agreement
      c2 = create :credit_agreement
      c3 = create :credit_agreement

      visit '/credit_agreements'
      fill_in :q_id_eq, with: c1.id
      click_on :suchen
      expect(page).to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c3.id}")
    end

    it "by account" do
      a1 = create :project_account
      a2 = create :project_account
      c1 = create :credit_agreement, account: a1
      c2 = create :credit_agreement, account: a1
      c3 = create :credit_agreement, account: a2

      visit '/credit_agreements'
      select a1.name, from: 'q_account_id_eq'
      click_on :suchen
      expect(page).to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c3.id}")
    end

    it "by creditors_name" do
      creditor = create :person, name: 'Albert'
      c1 = create :credit_agreement, creditor: creditor
      c2 = create :credit_agreement, creditor: creditor
      c3 = create :credit_agreement

      visit '/credit_agreements'
      fill_in :q_creditor_name_or_creditor_first_name_cont, with: 'lber'
      click_on :suchen
      expect(page).to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c3.id}")
    end

    it "by cancellation_period" do
      c1 = create :credit_agreement, cancellation_period: 5
      c2 = create :credit_agreement, cancellation_period: 4
      c3 = create :credit_agreement, cancellation_period: 3

      visit '/credit_agreements'
      fill_in :q_cancellation_period_lteq, with: '4'
      click_on :suchen
      expect(page).not_to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}")
    end

    it "by amount" do
      c1 = create :credit_agreement, amount: 20000 
      c2 = create :credit_agreement, amount: 30000 
      c3 = create :credit_agreement, amount: 10000 

      visit '/credit_agreements'
      fill_in :q_amount_gteq, with: '20000'
      click_on :suchen
      expect(page).to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c3.id}")
    end

    it "by interest_rate" do
      c1 = create :credit_agreement, interest_rate: 3 
      c2 = create :credit_agreement, interest_rate: 1.5 
      c3 = create :credit_agreement, interest_rate: 2

      visit '/credit_agreements'
      fill_in :q_interest_rate_gteq, with: '2'
      click_on :suchen
      expect(page).to have_css("tr#credit_agreement_#{c1.id}")
      expect(page).not_to have_css("tr#credit_agreement_#{c2.id}")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}")
    end
  end

  it "is paginated" do
    login_as create(:accountant)

    create_list :credit_agreement, 15, amount: 1111
    create_list :credit_agreement, 19, amount: 2222
    create_list :credit_agreement, 5, amount: 3333

    visit '/credit_agreements'
    expect(page).to have_content(number_to_currency(1111), count: 15 )
    expect(page).to_not have_content(number_to_currency(2222))
    expect(page).to_not have_content(number_to_currency(3333))

    click_on :next
    expect(page).to_not have_content(number_to_currency(1111))
    expect(page).to have_content(number_to_currency(2222), count: 15)
    expect(page).to_not have_content(number_to_currency(3333))

    click_on :next
    expect(page).to_not have_content(number_to_currency(1111))
    expect(page).to have_content(number_to_currency(2222), count: 4)
    expect(page).to have_content(number_to_currency(3333), count: 5)
  end

  describe "it is sortable" do
    before(:each){login_as create(:accountant)}

    it "default is id asc" do
      c1 = create :credit_agreement, id: 1
      c2 = create :credit_agreement, id: 2
      c3 = create :credit_agreement, id: 3

      visit '/credit_agreements'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(2)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(3)")
    end

    it "is resortable by id, cancellation_period, amount and interest_rate" do
      c1 = create :credit_agreement, id: 1, cancellation_period: 4, amount: 1111, interest_rate: 0
      c2 = create :credit_agreement, id: 2, cancellation_period: 5, amount: 3333, interest_rate: 3
      c3 = create :credit_agreement, id: 3, cancellation_period: 3, amount: 2222, interest_rate: 2

      visit credit_agreements_path(q: {s: ''})

      click_on 'Nr'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(2)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(3)")

      click_on 'Nr'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(2)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(1)")

      click_on 'Kündigungsfrist'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(2)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(1)")

      click_on 'Kündigungsfrist'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(2)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(3)")

      click_on 'Betrag'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(2)")

      click_on 'Betrag'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(2)")

      click_on 'Zinssatz'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(2)")

      click_on 'Zinssatz'
      expect(page).to have_css("tr#credit_agreement_#{c1.id}:nth-child(3)")
      expect(page).to have_css("tr#credit_agreement_#{c2.id}:nth-child(1)")
      expect(page).to have_css("tr#credit_agreement_#{c3.id}:nth-child(2)")
    end
  end
end
