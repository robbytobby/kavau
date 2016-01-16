require 'rails_helper'

RSpec.describe DepositLetter, type: :model do
  let(:type){ :deposit_letter }

  it_behaves_like "letter"

  it "title is the standard title if no Subject is given" do
    @letter = create :deposit_letter
    expect(@letter.title).to eq('Anschreiben für Zahlungseingang')
  end
end

