require 'rails_helper'

RSpec.describe StandardLetter, type: :model do
  before(:each){ @letter = create :standard_letter }

  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "knows that pdfs have not been created" do
    expect(@letter.pdfs_created?).to be_falsy
  end

  it "title is a synonym for subject" do
    expect(@letter.title).to eq(@letter.subject)
  end

  it "creates pdfs for each creditor" do
    create :person
    create :complete_project_address, legal_form: 'registered_society'
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
    allow(LetterPdf).to receive(:new).and_call_original
    @letter.to_pdf(person)
    expect(LetterPdf).to have_received(:new).with(person, @letter)
  end
end

