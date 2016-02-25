require 'rails_helper'

RSpec.describe BalanceLetterPdf do
  include ActionView::Helpers::NumberHelper

  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber' 
    @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    @credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
    create :deposit, amount: 1000, credit_agreement: @credit_agreement, date: Date.today.end_of_year.prev_year
    @deposit = create :deposit, amount: 2000, credit_agreement: @credit_agreement, date: Date.today
    @deposit.update_column(:date, Date.today.beginning_of_year.next_day(30) )
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today.end_of_year
    #@letter = create :balance_letter, year: Date.today.year, content: 'Covering Letter', subject: 'TheSubject'
    @pdf = InterestCertificatePdf.new([@balance])
    @days = Date.today.end_of_year.yday
  end

  it "has the right content" do
    page_analysis = PDF::Inspector::Page.analyze(@pdf.rendered)

    text_analysis = page_analysis.pages[0][:strings]
    #address_field
    expect(text_analysis).to include("Das Projekt GmbH")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include(I18n.l(Date.today))
    expect(text_analysis).to include("Zinsbescheinigung für das Jahr #{Date.today.year}")
    expect(text_analysis).to include("Dr. Albert Meier hat der Das Projekt GmbH einen zinsgünstigen Direktkredit zur")
    expect(text_analysis).to include("Verfügung gestellt, zur Unterstützung der sozialen Zwecke des selbstorganisiserten")
    expect(text_analysis).to include("Mietshausprojektes LaMa")
    expect(text_analysis).to include("Kreditvertrag-Nr")
    expect(text_analysis).to include("Jahreszinsbetrag #{@balance.date.year}")
    expect(text_analysis).to include(@credit_agreement.number)
    interest = (31.0 / @days * 0.02 * 1000).round(2)
    interest2 = ( (@days - 31).to_f / @days * 0.02 * 3000 ).round(2)
    expect(text_analysis).to include(number_to_currency(interest + interest2))
    expect(text_analysis).to include("Wir bedanken uns für die Unterstützung.")
    expect(text_analysis).to include("Das Projekt GmbH")

    #footer
    #FIXME: Bug in pdf-inspector: does not catch content from repeat(:all)

  end
end

