require 'rails_helper'

RSpec.describe PaymentLetter, type: :model do
  before(:each){ @letter = create :payment_letter }
  
  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "titel contains is the subject if given" do
    @letter = create :payment_letter, subject: 'Subject'
    expect(@letter.title).to eq('Subject')
  end

  it "title is the standard title if no Subject is given" do
    expect(@letter.title).to eq('Vorlage für Zahlungseingang')
  end


end
