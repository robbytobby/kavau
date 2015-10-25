require 'rails_helper'

[:user, :accountant, :admin].each do |type|
  RSpec.describe "manage your own account as #{type}"  do
    before(:each){ @user = create type }
    before(:each){ login_as @user }

    it "is possible to edit own account" do
      visit '/'
      click_on :edit_profile
      expect(current_path).to eq(edit_user_path(@user))
      expect(page).to_not have_css('select#user_role') if type != :admin
      fill_in :user_login, with: 'New Login'
      click_on :submit
      expect(current_path).to eq('/project')
      expect(page).to have_selector('div.alert-success')
    end

    it "is possible to cancel editing own account" do
      visit '/'
      click_on :edit_profile
      click_on :cancel
      expect(current_path).to eq('/project')
    end
  end
end
