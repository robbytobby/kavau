require "rails_helper"

RSpec.describe "addresses/new" do
  it "has the right fields for a person" do
    assign :address, create(:person)
    render 
    
    expect(rendered).to have_selector("input#person_salutation")
    expect(rendered).to have_selector("input#person_title")
    expect(rendered).to have_selector("input#person_first_name.required")
    expect(rendered).to have_selector("input#person_name.required")
    expect(rendered).to have_selector("input#person_email")
    expect(rendered).to have_selector("textarea#person_phone")
    expect(rendered).to have_selector("input#person_street_number.required")
    expect(rendered).to have_selector("input#person_zip.required")
    expect(rendered).to have_selector("input#person_city.required")
    expect(rendered).to have_selector("select#person_country_code.required")
    expect(rendered).to have_selector("textarea#person_notes")
    expect(rendered).not_to have_selector("input#person_type")
  end

  it "has the right fields for an organization" do
    assign :address, create(:organization)
    render 
    
    expect(rendered).to have_selector("input#organization_name.required")
    expect(rendered).to have_selector("input#organization_email")
    expect(rendered).to have_selector("textarea#organization_phone")
    expect(rendered).to have_selector("input#organization_street_number.required")
    expect(rendered).to have_selector("input#organization_zip.required")
    expect(rendered).to have_selector("input#organization_city.required")
    expect(rendered).to have_selector("select#organization_country_code.required")
    expect(rendered).to have_selector("textarea#organization_notes")
    expect(rendered).not_to have_selector("input#organization_type")
  end

  it "has the right fields for a project_address" do
    assign :address, create(:project_address)
    render 
    
    expect(rendered).to have_selector("input#project_address_name.required")
    expect(rendered).to have_selector("input#project_address_email")
    expect(rendered).to have_selector("textarea#project_address_phone")
    expect(rendered).to have_selector("input#project_address_street_number.required")
    expect(rendered).to have_selector("input#project_address_zip.required")
    expect(rendered).to have_selector("input#project_address_city.required")
    expect(rendered).to have_selector("select#project_address_country_code.required")
    expect(rendered).not_to have_selector("input#project_address_type")
  end
end
