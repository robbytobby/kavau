FactoryGirl.define do
  factory :balance do
    amount 0
    association :credit_agreement
    date Date.today
  end
end
