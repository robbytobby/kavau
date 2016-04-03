require 'rails_helper'

RSpec.describe "Settings for legal regulations of funds" do
  before(:each){ 
    login_as create(:accountant) 
    create :boolean_setting, category: 'legal_regulation', name: 'enforce_bagatelle_limits', value: true
    create :boolean_setting, category: 'legal_regulation', name: 'utilize_transitional_regulation', value: false
  }

  describe "enforce bagatelle limits" do
    it "limit none is not available for funds if setting is true" do
      #setting = Setting.find_by(name: 'enforce_bagatelle_limits')
      visit new_fund_path
      expect(page).not_to have_css("option[value='none']")
    end

    it "limit none is available for funds if setting is false" do
      setting = Setting.find_by(name: 'enforce_bagatelle_limits')
      setting.update_attributes(value: false)

      visit new_fund_path
      expect(page).to have_css("option[value='none']")
    end
  end

  describe "utilize_transitional_regulation" do
    it "the regulation takes effect from 2015-07-10 without transitional regulation" do
      expect(Fund.regulated_from).to eq Date.new(2015, 7, 10)
    end

    it "the regulation takes effect from 2016-01-01 with transitional regulation" do
      setting = Setting.find_by(name: 'utilize_transitional_regulation')
      setting.update_attributes(value: true)

      expect(Fund.regulated_from).to eq Date.new(2016, 1, 1)
    end
  end
end
