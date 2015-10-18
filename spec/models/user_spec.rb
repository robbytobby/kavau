require 'rails_helper'

RSpec.describe User do
  describe "a new user" do
    [:login, :first_name, :name, :email, :password, :password_confirmation].each do |attr|
      it "is not valid without #{attr}" do
        expect( build(:user, attr => nil) ).not_to be_valid
      end
    end
  end

  describe "password" do
    it "is valid if it contains lower_case, upper_case and numbers" do
      expect( build(:user, password: 'Asdfasd8', password_confirmation: 'Asdfasd8') ).to be_valid
    end

    it "is valid if it contains lower_case, upper_case and special letters" do
      expect( build(:user, password: 'Asdfasd!', password_confirmation: 'Asdfasd!') ).to be_valid
    end

    it "is not valid  without upper_case letter" do
      expect( build(:user, password: 'asdfasd8', password_confirmation: 'asdfasd8') ).not_to be_valid
    end

    it "is not valid  without lower_case letter" do
      expect( build(:user, password: 'ASDFASDF8', password_confirmation: 'ASDFASDF8') ).not_to be_valid
    end

    it "is not valid without non alphabetical letter" do
      expect( build(:user, password: 'ASDfASDF', password_confirmation: 'ASDfASDF') ).not_to be_valid
    end

    [:first_name, :name, :login].each do |attr|
      it "is not valid if it contains the #{attr} (case insensitive)" do
        expect( build(:user, 
                      attr => 'HansPeter', 
                      password: "kkkhansPeter1", 
                      password_confirmation: 'kkkhansPeter1') 
              ).not_to be_valid
      end
    end
  end

  describe "role" do
    it "valid are user, admin and accountant" do
      expect(User.valid_roles.sort).to eq(['accountant', 'admin', 'user'])
    end
    
    it "invalid roles are forbidden" do
      expect(build :user, role: 'invalid').not_to be_valid
    end

    it "knows its own role: user" do
      @user = create :user
      expect(@user).to be_user
      expect(@user).not_to be_accountant
      expect(@user).not_to be_admin
    end

    it "knows its own role: accountant" do
      @user = create :accountant
      expect(@user).not_to be_user
      expect(@user).to be_accountant
      expect(@user).not_to be_admin
    end

    it "knows its own role: admin" do
      @user = create :admin
      expect(@user).not_to be_user
      expect(@user).not_to be_accountant
      expect(@user).to be_admin
    end
  end
end

