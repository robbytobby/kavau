require 'rails_helper'

RSpec.describe "download payments as xlsx" do
  before(:each){
    @payment_1 = create :deposit, date: Date.today
    @payment_2 = create :disburse
    login_as create(:accountant)
  }

  it "works and has the correct content" do
    visit '/payments.xlsx'
    expect(page.response_headers['Content-Type']).to eq(Mime::XLSX.to_s)
    File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(page.source) }
    wb = nil
    expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.not_to raise_error
    expect(wb.cell(1, 1)).to eq 'ID'
    expect(wb.cell(1, 2)).to eq 'Datum'
    expect(wb.cell(1, 3)).to eq 'Art'
    expect(wb.cell(1, 4)).to eq 'Kreditgeber_in'
    expect(wb.cell(1, 5)).to eq 'Kreditvertrag Nr'
    expect(wb.cell(1, 6)).to eq 'Zinssatz'
    expect(wb.cell(1, 7)).to eq 'Konto'
    expect(wb.cell(1, 8)).to eq 'Betrag [€]'

    expect(wb.cell(2, 1)).to eq @payment_1.id
    expect(wb.cell(2, 2)).to eq @payment_1.date
    expect(wb.cell(2, 3)).to eq @payment_1.class.model_name.human
    expect(wb.cell(2, 4)).to eq [@payment_1.credit_agreement.creditor.name, @payment_1.credit_agreement.creditor.first_name].join(', ')
    expect(wb.cell(2, 5)).to eq @payment_1.credit_agreement.number.to_i
    expect(wb.cell(2, 6)).to eq @payment_1.credit_agreement.interest_rate/100
    expect(wb.cell(2, 7)).to eq @payment_1.credit_agreement.account.name
    expect(wb.cell(2, 8)).to eq @payment_1.amount

    expect(wb.cell(4, 1)).to eq @payment_2.id
    expect(wb.cell(4, 2)).to eq @payment_2.date
    expect(wb.cell(4, 3)).to eq @payment_2.class.model_name.human
    expect(wb.cell(4, 4)).to eq [@payment_2.credit_agreement.creditor.name, @payment_2.credit_agreement.creditor.first_name].join(', ')
    expect(wb.cell(4, 5)).to eq @payment_2.credit_agreement.number.to_i
    expect(wb.cell(4, 6)).to eq @payment_2.credit_agreement.interest_rate/100
    expect(wb.cell(4, 7)).to eq @payment_2.credit_agreement.account.name
    expect(wb.cell(4, 8)).to eq @payment_2.amount * @payment_2.sign
  end
end
