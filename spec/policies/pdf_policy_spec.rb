require 'rails_helper'

RSpec.describe PdfPolicy do
  before :each do
    allow_any_instance_of(StandardLetter).to receive(:to_pdf).and_return(true) 
    allow_any_instance_of(BalanceLetter).to receive(:to_pdf).and_return(true) 
    allow_any_instance_of(TerminationLetter).to receive(:to_pdf).and_return(true) 
  end

  subject { PdfPolicy.new(user, pdf) }
  let(:pdf) { create :pdf }

  context "for an admin" do
    let(:user){ create :admin }
    permits :all
  end

  context "for an accountant" do
    let(:user){ create :accountant }
    permits :all 
  end

  context "for a non privileged user" do
    let(:user){ create :user }
    permits :none
  end

  context "for balance letters" do
    let(:pdf) { create :pdf, letter: create(:balance_letter) }

    context "for an admin" do
      let(:user){ create :admin }
      permits :all
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits :all
    end
  end

  context "for balance letters and balane letter for next year exists" do
    before :each  do 
      @creditor = create :person
      create :pdf, letter: create(:balance_letter, year: 2015), creditor: @creditor
    end

    let(:pdf) { create :pdf, letter: create(:balance_letter, year: 2014), creditor: @creditor }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :show, :update]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :show, :update]
    end
  end

  context "for termination letters" do
    let(:pdf) { create :pdf, letter: create(:termination_letter) }

    context "for an admin" do
      let(:user){ create :admin }
      permits [:index, :show, :update, :new, :create]
    end

    context "for an accountant" do
      let(:user){ create :accountant }
      permits [:index, :show, :update, :new, :create]
    end
  end
end
