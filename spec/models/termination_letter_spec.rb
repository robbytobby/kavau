require 'rails_helper'

RSpec.describe TerminationLetter, type: :model do
  before(:each){ @letter = create :termination_letter, year: 2014 }

  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "knows that pdfs have not been created" do
    expect(@letter.pdfs_created?).to be_falsy
  end

  it "titel contains is the subject if given" do
    @letter = create :termination_letter, year: 2014, subject: 'Subject'
    expect(@letter.title).to eq('Subject')
  end

  it "title is the standard title if no Subject is given" do
    expect(@letter.title).to eq('Kündigungs-Schreiben')
  end

end

