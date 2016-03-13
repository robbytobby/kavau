RSpec.shared_examples "spreadsheet" do
  it "repsonds to presented" do
    expect(object.send(:presented)).to be_a(BasePresenter)
  end

  it "responds to spreadsheet_columns" do
    expect(object.public_methods).to include(:spreadsheet_columns)
  end
end

