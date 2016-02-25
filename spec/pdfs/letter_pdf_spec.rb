require 'rails_helper'

RSpec.describe LetterPdf do
  include ActionView::Helpers::NumberHelper
  before :each do 
    @creditor = create :person, name: 'Meier', first_name: 'Albert', title: 'Dr.',
        street_number: 'Strasse 1', zip: '79100', city: 'Freiburg'
    @letter = create :standard_letter, content: 'Something to tell', subject: 'TheSubject'
  end
  
  context "without a registered_society project address " do
    before :each do
      @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
        street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber',
        legal_form: 'limited' 
      @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
    end

    it "raises an error about it" do
      expect{
        @pdf = LetterPdf.new(@creditor, @letter)
      }.to raise_error(MissingRegisteredSocietyError)
    end

  end

  context "with project_address is registered_society" do
    before :each do
      @project_address = create :project_address, :with_legals, :with_contacts, name: 'Das Projekt',
        street_number: 'Weg 1', zip: '7800', city: "Städtl", email: 'info@example.org', phone: 'PhoneNumber',
        legal_form: 'registered_society' 
      @account = create :account, address: @project_address, bank: 'DiBaDu', default: true
      @pdf = LetterPdf.new(@creditor, @letter)
    end

    it "has the right content" do
      page_analysis = PDF::Inspector::Page.analyze(@pdf.render)
      expect(page_analysis.pages.size).to eq(1)

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
      expect(text_analysis).to include("Something to tell")

      #footer
      #FIXME: footer ist not found by PDFInspector (repeated content)
      #expect(text_analysis).to include("Das Projekt e.V.")
      #expect(text_analysis).to include("Court")
      #expect(text_analysis).to include(" RegistragionNumber | ")
      #expect(text_analysis).to include("Vorstand")
      #expect(text_analysis).to include(" Vorname Test Name")
      #expect(text_analysis).to include("DiBaDu")
      #expect(text_analysis).to include("BIC")
      #expect(text_analysis).to include(" GENODEF1S02 | ")
      #expect(text_analysis).to include("IBAN")
      #expect(text_analysis).to include(" RO49 AAAA 1B31 0075 9384 0000 | ")
    end
  end
end

