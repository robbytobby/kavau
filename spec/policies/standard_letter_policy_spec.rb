require 'rails_helper'

RSpec.describe StandardLetterPolicy do
  subject { StandardLetterPolicy.new(user, letter) }
  let(:letter) { FactoryBot.create(:standard_letter) }

  context "letter without pdfs" do
    before(:each){ allow_any_instance_of(StandardLetter).to receive(:pdfs_created?).and_return(false) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all, except: [:get_pdfs, :delete_pdfs]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all, except: [:get_pdfs, :delete_pdfs]
    end
  end

  context "letter with pdfs" do
    before(:each){ allow_any_instance_of(StandardLetter).to receive(:pdfs_created?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:get_pdfs, :delete_pdfs, :index, :show, :new, :create, :edit, :update]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:get_pdfs, :delete_pdfs, :index, :show, :new, :create, :edit, :update]
    end
  end

  context "letter with individual pdfs" do
    before(:each) do
      allow_any_instance_of(Letter).to receive(:pdfs).and_return([true]) 
    end

    context "for an admin" do
      let(:user){ create :admin }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update]
    end
  end


  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end
