FactoryGirl.define do
  factory :disburse do
    amount "999.99"
    type "Disburse"
    date "2015-10-31"
    association :credit_agreement
  end

  factory :deposit do
    amount "999.99"
    type "Deposit"
    date "2015-10-31"
    association :credit_agreement
  end
end
