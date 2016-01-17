require 'rails_helper'

RSpec.describe BalanceLetterPolicy do
  subject { BalanceLetterPolicy.new(user, letter) }
  let(:letter) { FactoryGirl.create(:balance_letter, year: 2014) }

  context "letter without pdfs" do
    before(:each){ allow_any_instance_of(BalanceLetter).to receive(:pdfs_created?).and_return(false) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:delete_pdfs, :get_pdfs]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:delete_pdfs, :get_pdfs]
    end
  end

  context "letter with pdfs" do
    before(:each){ allow_any_instance_of(BalanceLetter).to receive(:pdfs_created?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:create_pdfs, :destroy, :delete]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:create_pdfs, :destroy, :delete]
    end
  end

  context "letter with individual pdfs" do
    before(:each) do
      allow_any_instance_of(Letter).to receive(:pdfs).and_return([true]) 
    end

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:get_pdfs, :delete_pdfs, :destroy, :delete]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:get_pdfs, :delete_pdfs, :destroy, :delete]
    end
  end


  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end

  context "letter without year" do
    let(:letter) { FactoryGirl.create(:balance_letter) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:get_pdfs, :delete_pdfs]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:get_pdfs, :delete_pdfs]
    end
  end
end
