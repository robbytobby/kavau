require 'rails_helper'

RSpec.describe BalanceLetter, type: :model do
  before(:each){ @letter = create :balance_letter, year: 2014 }

  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "knows that pdfs have not been created" do
    expect(@letter.pdfs_created?).to be_falsy
  end

  it "title is the standard title even if Subject is given" do
    @letter = create :balance_letter, year: 2014, subject: 'Subject'
    expect(@letter.title).to eq('Jahresbilanz 2014')
  end

  it "title is the standard title if no Subject is given" do
    expect(@letter.title).to eq('Jahresbilanz 2014')
  end

  it "creates pdfs for each creditor with a balance for that year" do
    @person = create :person
    @address = create :complete_project_address, legal_form: 'registered_society'
    @credit_agreement = create :credit_agreement, creditor: @person, account: @address.default_account
    create :deposit, credit_agreement: @credit_agreement, date: Date.new(2014,11,11)
    create :person
    expect{
      @letter.create_pdfs
    }.to change(Pdf, :count).by(1)
  end
  
  it "knows if pdfs have been created" do
    create :person
    create :complete_project_address, legal_form: 'registered_society'
    @letter.create_pdfs
    expect(@letter.pdfs_created?).to be_truthy
  end

  it "builds pdfs from LetterPdf" do
    person = create :person
    create :complete_project_address, legal_form: 'registered_society'
    allow(YearlyBalancePdf).to receive(:new).and_call_original
    @letter.to_pdf(person)
    expect(YearlyBalancePdf).to have_received(:new).with(person, @letter)
  end
end

