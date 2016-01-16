require 'rails_helper'

RSpec.describe PaymentPdf do
  include ActionView::Helpers::NumberHelper

  [:disburse, :deposit].each do |type|
    before :each do
      @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
        street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
      @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
        street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber' 
      @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
      @credit_agreement = create :credit_agreement, account: @account, creditor: @creditor
      create :deposit, amount: 10000, credit_agreement: @credit_agreement, date: Date.yesterday
      @payment = create type, amount: 2000, credit_agreement: @credit_agreement, date: Date.today
      letter_content = '#PROJEKT_N received #BETRAG at #DATUM'
      @letter = create "#{type}_letter", content: letter_content, subject: 'TheSubject'
      @pdf = PaymentPdf.new(@payment)
    end

    it "has the right content" do
      page_analysis = PDF::Inspector::Page.analyze(@pdf.render)
      expect(page_analysis.pages.size).to eq(1)

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
      expect(text_analysis).to include("Betreff:")
      expect(text_analysis).to include(" TheSubject")
      expect(text_analysis).to include("Liebe Albert Meier,")
      expect(text_analysis).to include("die Das Projekt GmbH received #{number_to_currency(@payment.amount)} at #{I18n.l(@payment.date)}")

      #footer
      expect(text_analysis).to include("Das Projekt GmbH")
      expect(text_analysis).to include("Court")
      expect(text_analysis).to include(" RegistragionNumber | ")
      expect(text_analysis).to include("Geschäftsführung")
      expect(text_analysis).to include(" Vorname Test Name")
      expect(text_analysis).to include(" Vorname Test Name")
      expect(text_analysis).to include("DiBaDu")
      expect(text_analysis).to include("BIC")
      expect(text_analysis).to include(" GENODEF1S02 | ")
      expect(text_analysis).to include("IBAN")
      expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")
    end
  end  
end
