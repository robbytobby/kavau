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
end
