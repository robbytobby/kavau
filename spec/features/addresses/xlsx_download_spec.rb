require 'rails_helper'

RSpec.describe "download creditors as xlsx" do
  before(:each){
    @creditor_1 = create :person, notes: 'Notes', title: 'Titel', phone: 'Phone', email: 'test@test.org'
    @creditor_2 = create :organization
    login_as create(:accountant)
  }

  it "works and has the correct content" do
    visit '/creditors.xlsx'
    expect(page.response_headers['Content-Type']).to eq(Mime::XLSX.to_s)
    File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(page.source) }
    wb = nil
    expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.not_to raise_error
    expect(wb.cell(1, 1)).to eq 'Id'
    expect(wb.cell(1, 2)).to eq 'Anrede'
    expect(wb.cell(1, 3)).to eq 'Titel'
    expect(wb.cell(1, 4)).to eq 'Nachname'
    expect(wb.cell(1, 5)).to eq 'Vorname'
    expect(wb.cell(1, 6)).to eq 'Gesellschaftsform'
    expect(wb.cell(1, 7)).to eq 'Straße & Nr'
    expect(wb.cell(1, 8)).to eq 'PLZ'
    expect(wb.cell(1, 9)).to eq 'Stadt'
    expect(wb.cell(1,10)).to eq 'Land'
    expect(wb.cell(1,11)).to eq 'Email'
    expect(wb.cell(1,12)).to eq 'Telefon'
    expect(wb.cell(1,13)).to eq 'Notizen'

    expect(wb.cell(2, 1)).to eq @creditor_1.id
    expect(wb.cell(2, 2)).to eq 'Frau'
    expect(wb.cell(2, 3)).to eq 'Titel'
    expect(wb.cell(2, 4)).to eq @creditor_1.name
    expect(wb.cell(2, 5)).to eq @creditor_1.first_name
    expect(wb.cell(2, 6)).to eq nil
    expect(wb.cell(2, 7)).to eq @creditor_1.street_number
    expect(wb.cell(2, 8)).to eq @creditor_1.zip
    expect(wb.cell(2, 9)).to eq @creditor_1.city
    expect(wb.cell(2,10)).to eq 'Deutschland'
    expect(wb.cell(2,11)).to eq @creditor_1.email
    expect(wb.cell(2,12)).to eq @creditor_1.phone
    expect(wb.cell(2,13)).to eq 'Notes'

    expect(wb.cell(3, 1)).to eq @creditor_2.id
    expect(wb.cell(3, 2)).to eq nil
    expect(wb.cell(3, 3)).to eq nil
    expect(wb.cell(3, 4)).to eq @creditor_2.name
    expect(wb.cell(3, 5)).to eq nil
    expect(wb.cell(3, 6)).to eq 'GmbH'
    expect(wb.cell(3, 7)).to eq @creditor_2.street_number
    expect(wb.cell(3, 8)).to eq @creditor_2.zip
    expect(wb.cell(3, 9)).to eq @creditor_2.city
    expect(wb.cell(3,10)).to eq 'Deutschland'
    expect(wb.cell(3,11)).to eq @creditor_2.email
    expect(wb.cell(3,12)).to eq @creditor_2.phone
    expect(wb.cell(3,13)).to eq nil
  end
end
