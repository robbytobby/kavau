FactoryBot.define do
  factory :account do
    address { |a| a.association(:address) }
    sequence(:bank){ |n| "BANK_#{n}" }
    sequence(:name){ |n| "NAME_#{n}" }
    iban "RO49 AAAA 1B31 0075 9384 0000"
    bic 'GENODEF1S02'

    factory :project_account, class: Account do
      address { |a| a.association(:project_address) }
      address_type 'ProjectAddress'
    end

    factory :organization_account, class: Account do
      address { |a| a.association(:organization) }
    end

    factory :person_account, class: Account do
      address { |a| a.association(:person) }
    end
  end
end
