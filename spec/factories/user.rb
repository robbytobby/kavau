FactoryBot.define do
  factory :user do
    sequence(:email){|n| "mail#{n}@test.org"}
    sequence(:login){|n| "login_#{n}"}
    password { 'sECRETWORD1!' }
    password_confirmation { 'sECRETWORD1!' }
    first_name { 'First Name' }
    name { 'Name' }

    factory :accountant do
      role { 'accountant' }
    end

    factory :admin do
      role { 'admin' }
    end
  end
end
