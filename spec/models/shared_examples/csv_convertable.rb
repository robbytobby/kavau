RSpec.shared_examples "csv_convertable" do
  it "repsonds to presented" do
    expect(object.presented).to be_a(BasePresenter)
  end

  it "responds to csv_columns" do
    expect(object.csv_columns).to eq(object.class.csv_columns)
  end

  it "responds to to_csv" do
    expect(object).to respond_to(:to_csv)
  end
  
  it "class responds to csv_header" do
    expect(object.class).to respond_to(:csv_header)
  end
  
end

