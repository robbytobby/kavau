require 'rails_helper'

RSpec.describe DisburseLetterPolicy do
  subject { DisburseLetterPolicy.new(user, letter) }
  let(:letter) { FactoryGirl.build(:disburse_letter) }

  context "for an admin" do
    let(:user){ create :admin }
    permits :all, except: [:get_pdfs, :create_pdfs, :delete_pdfs]
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits :all, except: [:get_pdfs, :create_pdfs, :delete_pdfs]
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end

  context "a disburse letter exists" do
    before(:each){ FactoryGirl.create(:disburse_letter) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:new, :create, :get_pdfs, :create_pdfs, :delete_pdfs]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:new, :create, :get_pdfs, :create_pdfs, :delete_pdfs]
    end

  end
end
