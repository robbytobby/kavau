require 'rails_helper'

RSpec.describe Letter, type: :model do
  it "partial is letters/letter" do
    letter = create :letter
    expect(letter.to_partial_path).to eq('letters/letter')
  end

  it "knows that pdfs have not been created" do
    letter = create :letter
    expect(letter.pdfs_created?).to be_falsy
  end

  describe "knows its type" do
    it "termination_letter" do
      letter = create :termination_letter
      expect(letter).to be_termination_letter
    end

    it "standard_letter" do
      letter = create :standard_letter
      expect(letter).to be_standard_letter
    end

    it "standard_letter" do
      letter = create :balance_letter
      expect(letter).to be_balance_letter
    end
  end
end
