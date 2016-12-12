require 'rails_helper'

RSpec.describe "download balances as xlsx" do
  before(:each){
    @balance_1 = create :auto_balance, :pdf_ready
    @balance_2 = create :manual_balance
    @balance_3 = create :termination_balance
    login_as create(:accountant)
  }

  it "works and has the correct content" do
    visit '/balances.xlsx'
    expect(page.response_headers['Content-Type']).to eq(Mime::XLSX.to_s)
    File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(page.source) }
    wb = nil
    expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.not_to raise_error
    expect(wb.cell(1, 1)).to eq 'Saldo ID'
    expect(wb.cell(1, 2)).to eq 'Datum'
    expect(wb.cell(1, 3)).to eq 'KreditgeberIn'
    expect(wb.cell(1, 4)).to eq 'Kreditvertrag Nr'
    expect(wb.cell(1, 5)).to eq 'Zinssatz'
    expect(wb.cell(1, 6)).to eq 'Kontostand alt [€]'
    expect(wb.cell(1, 7)).to eq 'eingezahlt [€]'
    expect(wb.cell(1, 8)).to eq 'ausgezahlt [€]'
    expect(wb.cell(1, 9)).to eq 'Zinsen [€]'
    expect(wb.cell(1,10)).to eq 'Kontostand [€]'

    expect(wb.cell(2, 1)).to eq @balance_1.id
    expect(wb.cell(2, 2)).to eq @balance_1.date
    expect(wb.cell(2, 3)).to eq [@balance_1.creditor.name, @balance_1.creditor.first_name].join(', ')
    expect(wb.cell(2, 4)).to eq @balance_1.credit_agreement.number.to_i
    expect(wb.cell(2, 5)).to eq @balance_1.credit_agreement.interest_rate/100
    expect(wb.cell(2, 6)).to eq @balance_1.start_amount
    expect(wb.cell(2, 7)).to eq @balance_1.deposits
    expect(wb.cell(2, 8)).to eq @balance_1.disburses
    expect(wb.cell(2, 9)).to eq @balance_1.interests_sum
    expect(wb.cell(2,10)).to eq @balance_1.end_amount

    expect(wb.cell(3, 1)).to eq @balance_2.id
    expect(wb.cell(3, 2)).to eq @balance_2.date
    expect(wb.cell(3, 3)).to eq [@balance_2.creditor.name, @balance_2.creditor.first_name].join(', ')
    expect(wb.cell(3, 4)).to eq @balance_2.credit_agreement.number.to_i
    expect(wb.cell(3, 5)).to eq @balance_2.credit_agreement.interest_rate/100
    expect(wb.cell(3, 6)).to eq @balance_2.start_amount
    expect(wb.cell(3, 7)).to eq @balance_2.deposits
    expect(wb.cell(3, 8)).to eq @balance_2.disburses
    expect(wb.cell(3, 9)).to eq @balance_2.interests_sum
    expect(wb.cell(3,10)).to eq @balance_2.end_amount

    expect(wb.cell(4, 1)).to eq @balance_3.id
    expect(wb.cell(4, 2)).to eq @balance_3.date
    expect(wb.cell(4, 3)).to eq [@balance_3.creditor.name, @balance_3.creditor.first_name].join(', ')
    expect(wb.cell(4, 4)).to eq @balance_3.credit_agreement.number.to_i
    expect(wb.cell(4, 5)).to eq @balance_3.interest_rate/100
    expect(wb.cell(4, 6)).to eq @balance_3.start_amount
    expect(wb.cell(4, 7)).to eq @balance_3.deposits
    expect(wb.cell(4, 8)).to eq @balance_3.disburses
    expect(wb.cell(4, 9)).to eq @balance_3.interests_sum
    expect(wb.cell(4,10)).to eq @balance_3.end_amount
  end
end
