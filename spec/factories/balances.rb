FactoryGirl.define do
  factory :balance, class: 'AutoBalance' do
    association :credit_agreement
    date Date.today
  end

  factory :auto_balance, parent: :balance do
  end

  factory :manual_balance, class: 'ManualBalance' do
    association :credit_agreement
    date Date.today
    end_amount 10000
  end
end
