FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "mail#{n}@test.org"}
    password 'SECRETWORD'
  end
end
