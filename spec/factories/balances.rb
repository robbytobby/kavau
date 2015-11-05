FactoryGirl.define do
  factory :balance do
    association :credit_agreement
    date Date.today
  end
end
