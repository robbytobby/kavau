require 'rails_helper'

RSpec.describe "download credit agreements as xlsx" do
  before(:each){
    @credit_agreement_1 = create :credit_agreement, amount: 10000, interest_rate: 1.2, number: 'K1'
    @credit_agreement_2 = create :credit_agreement, amount: 20000, interest_rate: 2, number: 'K2'
    @credit_agreement_2.update_column(:terminated_at, Date.today)
    login_as create(:accountant)
  }

  it "works and has the correct content" do
    visit '/credit_agreements.xlsx'
    expect(page.response_headers['Content-Type']).to eq(Mime::XLSX.to_s)
    File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(page.source) }
    wb = nil
    expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.not_to raise_error
    expect(wb.cell(1, 1)).to eq 'ID'
    expect(wb.cell(1, 2)).to eq 'Nummer'
    expect(wb.cell(1, 3)).to eq 'Betrag [€]'
    expect(wb.cell(1, 4)).to eq 'Zinssatz p.a. [%]'
    expect(wb.cell(1, 5)).to eq 'Kündigungsfrist [Monate]'
    expect(wb.cell(1, 6)).to eq 'Kreditgeber_in'
    expect(wb.cell(1, 7)).to eq 'Kreditgeber_in ID'
    expect(wb.cell(1, 8)).to eq 'Konto'
    expect(wb.cell(1, 9)).to eq 'Konto ID'
    expect(wb.cell(1,10)).to eq 'getilgt am'

    expect(wb.cell(2, 1)).to eq @credit_agreement_1.id
    expect(wb.cell(2, 2)).to eq @credit_agreement_1.number
    expect(wb.cell(2, 3)).to eq @credit_agreement_1.amount
    expect(wb.cell(2, 4)).to eq @credit_agreement_1.interest_rate / 100
    expect(wb.cell(2, 5)).to eq @credit_agreement_1.cancellation_period
    expect(wb.cell(2, 6)).to eq [@credit_agreement_1.creditor.name, @credit_agreement_1.creditor.first_name].join(', ')
    expect(wb.cell(2, 7)).to eq @credit_agreement_1.creditor.id
    expect(wb.cell(2, 8)).to eq @credit_agreement_1.account.name
    expect(wb.cell(2, 9)).to eq @credit_agreement_1.account.id
    expect(wb.cell(2,10)).to eq @credit_agreement_1.terminated_at

    expect(wb.cell(3, 1)).to eq @credit_agreement_2.id
    expect(wb.cell(3, 2)).to eq @credit_agreement_2.number
    expect(wb.cell(3, 3)).to eq @credit_agreement_2.amount
    expect(wb.cell(3, 4)).to eq @credit_agreement_2.interest_rate / 100
    expect(wb.cell(3, 5)).to eq @credit_agreement_2.cancellation_period
    expect(wb.cell(3, 6)).to eq [@credit_agreement_2.creditor.name, @credit_agreement_2.creditor.first_name].join(', ')
    expect(wb.cell(3, 7)).to eq @credit_agreement_2.creditor.id
    expect(wb.cell(3, 8)).to eq @credit_agreement_2.account.name
    expect(wb.cell(3, 9)).to eq @credit_agreement_2.account.id
    expect(wb.cell(3,10)).to eq @credit_agreement_2.terminated_at
  end
end
