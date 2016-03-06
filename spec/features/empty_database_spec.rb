require 'rails_helper'

RSpec.describe "Flashes lead the user to setup a new instance of kavau" do
  describe "if settings are missing" do
    it "an admin is redirected to Settings page" do
      login_as create(:admin)  
      create_default_settings
      visit '/'
      expect(current_path).to eq('/settings')
      within 'div.alert-alert' do
        expect(page).to have_content 'Die Konfiguration ist nicht vollständig'
      end
    end

    [:accountant, :user].each do |role|
      it "a #{role} is informed about it" do
        login_as create role
        create_default_settings
        visit '/'
        expect(current_path).to eq('/')
        within 'div.alert-alert' do
          expect(page).to have_content 'Die Konfiguration ist nicht vollständig'
        end
      end
    end
  end
end
