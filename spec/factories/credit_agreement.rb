FactoryBot.define do
  factory :raw_credit_agreement, class: CreditAgreement do
    amount "10000.00"
    interest_rate "2.00"
    cancellation_period 3
    association :creditor, factory: :person
    association :account, factory: :project_account
    sequence(:number){|n| n.to_s}
    valid_from Date.today

    factory :credit_agreement do
      after(:build){ |object|
        unless object.fund
          create :fund, issued_at: object.valid_from, interest_rate: object.interest_rate, project_address: object.account.address
        end
      }
    end
  end

  trait :with_payment do
    after(:create) { |object| create :deposit, credit_agreement: object }
  end
end
