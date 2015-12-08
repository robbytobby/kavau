require 'rails_helper'

RSpec.describe LetterPolicy do
  subject { LetterPolicy.new(user, letter) }
  let(:letter) { FactoryGirl.create(:letter) }

  context "letter without pdfs" do
    before(:each){ allow_any_instance_of(Letter).to receive(:pdfs_created?).and_return(false) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end
  end

  context "letter with pdfs created" do
    before(:each) do
      allow_any_instance_of(Letter).to receive(:pdfs_created?).and_return(true) 
    end

    context "for an admin" do
      let(:user){ create :admin }
      permits [:get_pdfs, :index, :show, :new, :create, :edit, :update]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:get_pdfs, :index, :show, :new, :create, :edit, :update]
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
