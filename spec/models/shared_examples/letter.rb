RSpec.shared_examples "letter" do
  before(:each){ @letter = create type, subject: 'Subject' }

  it "partial is letters/letter" do
    expect(@letter.to_partial_path).to eq('letters/letter')
  end

  it "titel contains is the subject if given" do
    expect(@letter.title).to eq('Subject')
  end
end

