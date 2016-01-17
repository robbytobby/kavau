RSpec.shared_examples "pdf_downloadable" do
  let(:object){ array.first }

  it "assigns all balances in @q" do
    expect(assigns(:q).result).to eq(array)
  end

  it "is successfull" do
    expect(response).to have_http_status(200)
  end

  it "delivers the right file-headers" do
    expect(response.header["Content-Type"]).to eq('text/csv')
    expect(response.header["Content-Disposition"]).to eq("attachment; filename=#{filename}")
  end

  it "the delivered file has the right header-line" do
    header = response.body.split("\n").first.split("\t")
    expect(header).to eq(headerline)
  end

  it "the delivered file has the right content" do
    content = response.body.split("\n").second.split("\t")
    expect(content).to include(*contentline)
  end

  def filename
     I18n.t(controller.controller_name, scope: :controller_names) + '.csv'
  end

  def headerline
    object.csv_columns.map{ |key| I18n.t(key.to_s, scope: ['csv', csv_key]) }
  end

  def csv_key
    (assigns(:type) || controller.controller_name.singularize).underscore
  end

  def contentline
    object.to_csv.compact.map(&:to_s)
  end
end

