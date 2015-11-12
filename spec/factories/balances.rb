FactoryGirl.define do
  factory :balance do
    association :credit_agreement
    date Date.today

    trait :manual do
      manually_edited true
      end_amount 10000
    end
  end
end
