require 'rails_helper'

RSpec.describe StandardLetterPolicy do
  subject { StandardLetterPolicy.new(user, letter) }
  let(:letter) { FactoryGirl.create(:standard_letter) }

  context "letter without pdfs" do
    before(:each){ allow_any_instance_of(StandardLetter).to receive(:pdfs_created?).and_return(false) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:create_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end
  end

  context "letter with pdfs" do
    before(:each){ allow_any_instance_of(StandardLetter).to receive(:pdfs_created?).and_return(true) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:get_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:get_pdfs, :index, :show, :new, :create, :edit, :update, :destroy]
    end
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end
end
