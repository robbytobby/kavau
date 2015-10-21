FactoryGirl.define do
  factory :account do
    address { |a| a.association(:address) }
    sequence(:bic){ |n| "BIC_#{n}" }
    sequence(:iban){ |n| "IBAN_#{n}" }
    sequence(:bank){ |n| "BANK_#{n}" }
    sequence(:name){ |n| "NAME_#{n}" }

    factory :project_account, class: Account do
      address { |a| a.association(:project_address) }
    end

    factory :organization_account, class: Account do
      address { |a| a.association(:organization) }
    end

    factory :person_account, class: Account do
      address { |a| a.association(:person) }
    end
  end
end
