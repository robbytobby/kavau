require 'rails_helper'

RSpec.describe "Generating PDFs for letters" do
  before(:each){ 
    login_as create(:accountant) 
    create :person
    create :complete_project_address, legal_form: 'registered_society'
  } 

  it "I can create pdfs for standard letters for all creditors" do
    letter = create :standard_letter
    visit '/letters'
    click_on "create_pdfs_standard_letter_#{letter.id}"
    expect(current_path).to eq('/letters')
    expect(page).to have_selector('div.alert-notice')
    click_on "get_pdfs_standard_letter_#{letter.id}"
    #TODO: spec the resulting combined pdf
  end

  it "I can delete pdfs for standard letters for all creditors" do
    letter = create :standard_letter
    letter.create_pdfs
    visit '/letters'
    click_on "delete_pdfs_standard_letter_#{letter.id}"
    expect(current_path).to eq('/letters')
    expect(page).to have_selector('div.alert-notice')
    expect(letter.pdfs.count).to eq(0)
  end
end
