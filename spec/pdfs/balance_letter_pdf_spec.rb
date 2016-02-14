require 'rails_helper'

RSpec.describe BalanceLetterPdf do
  include ActionView::Helpers::NumberHelper

  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
      legal_form: 'registered_society', street_number: 'Weg 1', zip: '7800', city: "Städtl", 
      email: 'info@example.org', phone: 'PhoneNumber' 
    @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    @credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
    create :deposit, amount: 1000, credit_agreement: @credit_agreement, date: Date.today.end_of_year.prev_year
    @deposit = create :deposit, amount: 2000, credit_agreement: @credit_agreement, date: Date.today
    @deposit.update_column(:date, Date.today.beginning_of_year.next_day(30) )
    @balance = create :balance, credit_agreement: @credit_agreement, date: Date.today.end_of_year
    @letter = create :balance_letter, year: Date.today.year, content: 'Covering Letter', subject: 'TheSubject'
    @pdf = BalanceLetterPdf.new(@balance)
    @days = Date.today.end_of_year.yday
  end

  it "has the right content" do
    page_analysis = PDF::Inspector::Page.analyze(@pdf.render)
    expect(page_analysis.pages.size).to eq(3)

    ### FIRST PAGE: covering letter
    text_analysis = page_analysis.pages[0][:strings]
    #address_field
    expect(text_analysis).to include("Das Projekt e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include(I18n.l(Date.today))
    expect(text_analysis).to include("Betreff:")
    expect(text_analysis).to include(" TheSubject")
    expect(text_analysis).to include("Covering Letter")

    #footer
    #expect(text_analysis).to include("Das Projekt GmbH")
    #expect(text_analysis).to include("Court")
    #expect(text_analysis).to include(" RegistragionNumber | ")
    #expect(text_analysis).to include("Geschäftsführung")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include("DiBaDu")
    #expect(text_analysis).to include("BIC")
    #expect(text_analysis).to include(" GENODEF1S02 | ")
    #expect(text_analysis).to include("IBAN")
    #expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### SECOND PAGE: balance
    text_analysis = page_analysis.pages[1][:strings]
    #address_field
    expect(text_analysis).to include("Das Projekt e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include("Kreditvertrag Nr #{@credit_agreement.number} - Jahresabschluss #{@balance.date.year}")
    expect(text_analysis).to include("Datum")
    expect(text_analysis).to include("Zinstage")
    expect(text_analysis).to include("Zinsberechnung")
    expect(text_analysis).to include("Betrag")
    expect(text_analysis).to include(I18n.l(Date.today.prev_year.end_of_year))
    expect(text_analysis).to include(number_to_currency(1000))
    expect(text_analysis).to include('31')
    expect(text_analysis).to include("31 / #{@days} x 2,00% x 1.000,00 €")
    interest = (31.0 / @days * 0.02 * 1000).round(2)
    expect(text_analysis).to include(number_to_currency(interest))
    expect(text_analysis).to include("Einzahlung")
    expect(text_analysis).to include("2.000,00 €")
    expect(text_analysis).to include("#{@days - 31}")
    expect(text_analysis).to include("#{@days - 31} / #{@days} x 2,00% x 3.000,00 €")
    interest2 = ( (@days - 31).to_f / @days * 0.02 * 3000 ).round(2)
    expect(text_analysis).to include(number_to_currency(interest2))
    expect(text_analysis).to include("Saldo")
    expect(text_analysis).to include("Zinsen")
    expect(text_analysis).to include(I18n.l(Date.today.end_of_year))
    expect(text_analysis).to include(number_to_currency(3000 + interest + interest2))

    #footer
    #expect(text_analysis).to include("Das Projekt GmbH")
    #expect(text_analysis).to include("Court")
    #expect(text_analysis).to include(" RegistragionNumber | ")
    #expect(text_analysis).to include("Geschäftsführung")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include("DiBaDu")
    #expect(text_analysis).to include("BIC")
    #expect(text_analysis).to include(" GENODEF1S02 | ")
    #expect(text_analysis).to include("IBAN")
    #expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### THIRD PAGE: interest certificate
    text_analysis = page_analysis.pages[2][:strings]
    #address_field
    expect(text_analysis).to include("Das Projekt e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include(I18n.l(Date.today))
    expect(text_analysis).to include("Zinsbescheinigung für das Jahr #{Date.today.year}")
    expect(text_analysis).to include("Dr. Albert Meier hat dem Das Projekt e.V. einen zinsgünstigen Direktkredit zur Verfügung")
    expect(text_analysis).to include("gestellt, zur Unterstützung der sozialen Zwecke des selbstorganisiserten")
    expect(text_analysis).to include("Mietshausprojektes LAMA")
    expect(text_analysis).to include("Kreditvertrag-Nr")
    expect(text_analysis).to include("Jahreszinsbetrag #{@balance.date.year}")
    expect(text_analysis).to include(@credit_agreement.number)
    expect(text_analysis).to include(number_to_currency(interest + interest2))
    expect(text_analysis).to include("Wir bedanken uns für die Unterstützung.")
    expect(text_analysis).to include("Das Projekt e.V.")

    #footer
    #expect(text_analysis).to include("Das Projekt GmbH")
    #expect(text_analysis).to include("Court")
    #expect(text_analysis).to include(" RegistragionNumber | ")
    #expect(text_analysis).to include("Geschäftsführung")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include(" Vorname Test Name")
    #expect(text_analysis).to include("DiBaDu")
    #expect(text_analysis).to include("BIC")
    #expect(text_analysis).to include(" GENODEF1S02 | ")
    #expect(text_analysis).to include("IBAN")
    #expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

  end
end

