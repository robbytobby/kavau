require 'rails_helper'

RSpec.describe BalancePdf do
  include ActionView::Helpers::NumberHelper

  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber' 
    @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    @credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
    create :deposit, amount: 1000, credit_agreement: @credit_agreement, date: Date.today.end_of_year.prev_year
    @deposit = create :deposit, amount: 2000, credit_agreement: @credit_agreement, date: Date.today.beginning_of_year.next_day(30)
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today.end_of_year
    @letter = BalanceLetter.create(content: 'Text')
    @pdf = BalancePdf.new(@balance)
  end

  it "stores the balance" do
    expect(@pdf.instance_variable_get('@balance')).to eq(@balance)
  end

  it "has the right content" do
    text_analysis = PDF::Inspector::Text.analyze(@pdf.render).strings 
    expect(text_analysis).to include("Kreditvertrag Nr #{@credit_agreement.id} - Jahresabschluss #{@balance.date.year}")
    expect(text_analysis).to include("Datum")
    expect(text_analysis).to include("Zinstage")
    expect(text_analysis).to include("Zinsberechnung")
    expect(text_analysis).to include("Betrag")
    expect(text_analysis).to include(I18n.l(Date.today.prev_year.end_of_year))
    expect(text_analysis).to include(number_to_currency(1000))
    expect(text_analysis).to include('31')
    expect(text_analysis).to include("31 / 365 x 2,00% x 1.000,00 €")
    expect(text_analysis).to include("1,70 €")
    expect(text_analysis).to include("Einzahlung")
    expect(text_analysis).to include("2.000,00 €")
    expect(text_analysis).to include("334")
    expect(text_analysis).to include("334 / 365 x 2,00% x 3.000,00 €")
    expect(text_analysis).to include("54,90 €")
    expect(text_analysis).to include("Saldo")
    expect(text_analysis).to include("Zinsen")
    expect(text_analysis).to include(I18n.l(Date.today.end_of_year))
    expect(text_analysis).to include("3.056,60 €")
  end
end

