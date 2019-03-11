FactoryBot.define do
  factory :pdf do
    association :letter, factory: :standard_letter
    association :creditor, factory: :person

    before :create do
      create :complete_project_address, legal_form: 'registered_society'
    end
  end
end
