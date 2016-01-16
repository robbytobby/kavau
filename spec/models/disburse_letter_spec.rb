require 'rails_helper'

RSpec.describe DisburseLetter, type: :model do
  let(:type){ :disburse_letter }

  it_behaves_like "letter"

  it "title is the standard title if no Subject is given" do
    @letter = create :disburse_letter
    expect(@letter.title).to eq('Anschreiben für Rückzahlungen')
  end
end

