RSpec.shared_examples "xlsx_downloadable" do
  let(:object){ array.first }

  it "assigns all records in the collection instance" do
    expect(assigns(collection_name)).to eq(array)
  end

  it "is successfull" do
    expect(response).to have_http_status(200)
  end

  it "delivers the right file-headers" do
    expect(response.header["Content-Type"]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    expect(response.header["Content-Disposition"]).to eq("attachment; filename=\"#{collection_name.to_s.camelize}.xlsx\"")
  end
end

