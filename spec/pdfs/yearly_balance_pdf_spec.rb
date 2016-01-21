require 'rails_helper'

RSpec.describe YearlyBalancePdf do
  include ActionView::Helpers::NumberHelper

  before :each do
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
      street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @ev_address = create :project_address, :with_legals, :with_contacts, name: 'Der Verein',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber',
      legal_form: 'registered_society'
    @gmbh_address = create :project_address, :with_legals, :with_contacts, name: 'Die Gmbh',
      street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber',
      legal_form: 'limited'
    @ev_account1 = create :account, address: @ev_address, bank: 'DiBaDu', default: true
    @ev_account2 = create :account, address: @ev_address, bank: 'DuBaDi'
    @gmbh_account = create :account, address: @gmbh_address, bank: 'Sparkasse', default: true

    @credit_agreement1 = create :credit_agreement, account: @ev_account1, creditor: @creditor, interest_rate: 0
    @credit_agreement2 = create :credit_agreement, account: @ev_account2, creditor: @creditor, interest_rate: 1
    @credit_agreement3 = create :credit_agreement, account: @gmbh_account, creditor: @creditor, interest_rate: 2
    create :deposit, amount: 1000, credit_agreement: @credit_agreement1, date: Date.today.end_of_year.prev_year
    create :deposit, amount: 2000, credit_agreement: @credit_agreement2, date: Date.today.end_of_year.prev_year
    create :deposit, amount: 3000, credit_agreement: @credit_agreement3, date: Date.today.end_of_year.prev_year
    @balance1 = create :balance, credit_agreement: @credit_agreement1, date: Date.today.end_of_year
    @balance2 = create :balance, credit_agreement: @credit_agreement2, date: Date.today.end_of_year
    @balance3 = create :balance, credit_agreement: @credit_agreement3, date: Date.today.end_of_year
    @letter = create :balance_letter, year: Date.today.year, content: 'Covering Letter', subject: 'TheSubject'
    @pdf = YearlyBalancePdf.new(@creditor, @letter)
  end

  it "has the right content" do
    year_days = Date.today.end_of_year.yday
    page_analysis = PDF::Inspector::Page.analyze(@pdf.render)
    expect(page_analysis.pages.size).to eq(6)

    ### FIRST PAGE: covering letter
    text_analysis = page_analysis.pages[0][:strings]
    #address_field
    expect(text_analysis).to include("Der Verein e.V.")
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
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Vorstand")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("DiBaDu")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### SECOND PAGE: balance1
    text_analysis = page_analysis.pages[1][:strings]
    #address_field
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include("Kreditvertrag Nr #{@credit_agreement1.number} - Jahresabschluss #{@balance1.date.year}")
    expect(text_analysis).to include("Datum")
    expect(text_analysis).to include("Zinstage")
    expect(text_analysis).to include("Zinsberechnung")
    expect(text_analysis).to include("Betrag")
    expect(text_analysis).to include(I18n.l(Date.today.prev_year.end_of_year))
    expect(text_analysis).to include("Saldo")
    expect(text_analysis).to include(number_to_currency(1000))
    expect(text_analysis).to include("Zinsen")
    expect(text_analysis).to include(year_days.to_s)
    expect(text_analysis).to include("#{year_days} / #{year_days} x 0,00% x 1.000,00 €")
    expect(text_analysis).to include("0,00 €")
    expect(text_analysis).to include(I18n.l(Date.today.end_of_year))
    expect(text_analysis).to include("Die Berechnung der Zinstage erfolgt nach der Effektivzinsmethode. Informationen zur Zinsmethode befinden")
    expect(text_analysis).to include("sich auf unserer Website unter lamakat.de/direktkredite/article/zinsmethode.")

    #footer
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Vorstand")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("DiBaDu")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### Third PAGE: balance2
    text_analysis = page_analysis.pages[2][:strings]
    #address_field
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include("Kreditvertrag Nr #{@credit_agreement2.number} - Jahresabschluss #{@balance2.date.year}")
    expect(text_analysis).to include("Datum")
    expect(text_analysis).to include("Zinstage")
    expect(text_analysis).to include("Zinsberechnung")
    expect(text_analysis).to include("Betrag")
    expect(text_analysis).to include(I18n.l(Date.today.prev_year.end_of_year))
    expect(text_analysis).to include("Saldo")
    expect(text_analysis).to include(number_to_currency(2000))
    expect(text_analysis).to include("Zinsen")
    expect(text_analysis).to include("#{year_days}")
    expect(text_analysis).to include("#{year_days} / #{year_days} x 1,00% x 2.000,00 €")
    expect(text_analysis).to include("20,00 €")
    expect(text_analysis).to include(I18n.l(Date.today.end_of_year))
    expect(text_analysis).to include("Die Berechnung der Zinstage erfolgt nach der Effektivzinsmethode. Informationen zur Zinsmethode befinden")
    expect(text_analysis).to include("sich auf unserer Website unter lamakat.de/direktkredite/article/zinsmethode.")

    #footer
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Vorstand")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("DiBaDu")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### PAGE 4: balance3
    text_analysis = page_analysis.pages[3][:strings]
    #address_field
    expect(text_analysis).to include("Die Gmbh GmbH")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")

    #main part
    expect(text_analysis).to include("Kreditvertrag Nr #{@credit_agreement3.number} - Jahresabschluss #{@balance3.date.year}")
    expect(text_analysis).to include("Datum")
    expect(text_analysis).to include("Zinstage")
    expect(text_analysis).to include("Zinsberechnung")
    expect(text_analysis).to include("Betrag")
    expect(text_analysis).to include(I18n.l(Date.today.prev_year.end_of_year))
    expect(text_analysis).to include("Saldo")
    expect(text_analysis).to include(number_to_currency(3000))
    expect(text_analysis).to include("Zinsen")
    expect(text_analysis).to include("#{year_days}")
    expect(text_analysis).to include("#{year_days} / #{year_days} x 2,00% x 3.000,00 €")
    expect(text_analysis).to include("60,00 €")
    expect(text_analysis).to include(I18n.l(Date.today.end_of_year))
    expect(text_analysis).to include("Die Berechnung der Zinstage erfolgt nach der Effektivzinsmethode. Informationen zur Zinsmethode befinden")
    expect(text_analysis).to include("sich auf unserer Website unter lamakat.de/direktkredite/article/zinsmethode.")

    #footer
    expect(text_analysis).to include("Die Gmbh GmbH")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Geschäftsführung")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("Sparkasse")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### PAGE 5: interest_certificate 1 
    text_analysis = page_analysis.pages[4][:strings]
    #
    #address_field
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")
    #
    #main part
    expect(text_analysis).to include(I18n.l(Date.today))
    expect(text_analysis).to include("Zinsbescheinigung für das Jahr #{Date.today.year}")
    expect(text_analysis).to include("Dr. Albert Meier hat dem Der Verein e.V. zinsgünstige Direktkredite zur Verfügung gestellt,")
    expect(text_analysis).to include("zur Unterstützung der sozialen Zwecke des selbstorganisiserten Mietshausprojektes")
    expect(text_analysis).to include("LAMA")
    expect(text_analysis).to include("Kreditvertrag-Nr")
    expect(text_analysis).to include("Jahreszinsbetrag #{@balance1.date.year}")
    expect(text_analysis).not_to include(@credit_agreement1.number)
    expect(text_analysis).to include(@credit_agreement2.number)
    expect(text_analysis).not_to include("0,00 €")
    expect(text_analysis).to include("20,00 €")
    expect(text_analysis).to include("20,00 €")
    expect(text_analysis).to include("Wir bedanken uns für die Unterstützung.")
    expect(text_analysis).to include("Der Verein e.V.")
    #
    #footer
    expect(text_analysis).to include("Der Verein e.V.")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Vorstand")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("DiBaDu")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")

    ### PAGE 6: interest_certificate 2 
    text_analysis = page_analysis.pages[5][:strings]
    #
    #address_field
    expect(text_analysis).to include("Die Gmbh GmbH")
    expect(text_analysis).to include(" | Weg 1 | 7800 Städtl")
    expect(text_analysis).to include("Dr. Albert Meier")
    expect(text_analysis).to include("Strasse 1")
    expect(text_analysis).to include("79100 Freiburg")
    expect(text_analysis).to include("Deutschland")
    #
    #main part
    expect(text_analysis).to include(I18n.l(Date.today))
    expect(text_analysis).to include("Zinsbescheinigung für das Jahr #{Date.today.year}")
    expect(text_analysis).to include("Dr. Albert Meier hat der Die Gmbh GmbH einen zinsgünstigen Direktkredit zur Verfügung")
    expect(text_analysis).to include("gestellt, zur Unterstützung der sozialen Zwecke des selbstorganisiserten")
    expect(text_analysis).to include("Mietshausprojektes LAMA")
    expect(text_analysis).to include("Kreditvertrag-Nr")
    expect(text_analysis).to include("Jahreszinsbetrag #{@balance3.date.year}")
    expect(text_analysis).to include(@credit_agreement3.number)
    expect(text_analysis).to include("60,00 €")
    expect(text_analysis).to include("Wir bedanken uns für die Unterstützung.")
    expect(text_analysis).to include("Die Gmbh GmbH")
    #
    #footer
    expect(text_analysis).to include("Die Gmbh GmbH")
    expect(text_analysis).to include("Court")
    expect(text_analysis).to include(" RegistragionNumber | ")
    expect(text_analysis).to include("Geschäftsführung")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include(" Vorname Test Name")
    expect(text_analysis).to include("Sparkasse")
    expect(text_analysis).to include("BIC")
    expect(text_analysis).to include(" GENODEF1S02 | ")
    expect(text_analysis).to include("IBAN")
    expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")
  end
end

