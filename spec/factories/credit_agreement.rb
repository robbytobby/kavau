FactoryGirl.define do
  factory :credit_agreement do
    amount "10000.00"
    interest_rate "2.00"
    cancellation_period 3
    association :creditor, factory: :person
    association :account, factory: :project_account
  end

end
