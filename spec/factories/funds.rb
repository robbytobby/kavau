FactoryGirl.define do
  factory :fund do
    interest_rate 9.99
    limit 'number_of_shares'
    issued_at Date.today
  end
end
