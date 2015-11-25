FactoryGirl.define do
  factory :balance, class: 'AutoBalance' do
    association :credit_agreement
    date Date.today
    
    trait :pdf_ready do
      before :create do |balance|
        project_address = create :complete_project_address
        credit_agreement = create :credit_agreement, account: project_address.default_account
        create :deposit, credit_agreement: credit_agreement
        balance.credit_agreement = credit_agreement
      end
    end
  end

  factory :auto_balance, parent: :balance do
  end

  factory :manual_balance, class: 'ManualBalance' do
    association :credit_agreement
    date Date.today
    end_amount 10000
  end

  factory :termination_balance, class: 'TerminationBalance' do
    association :credit_agreement
    date Date.today
  end
end
