FactoryGirl.define do
  factory :address do
    type 'Address'
    name 'Test Name' 
    street_number "Test Street"
    zip "Test Zip"
    city "Test City"
    country_code "DE"

    factory :project_address, class: ProjectAddress do
      type "ProjectAddress"
      legal_form 'limited'

      trait :with_legals do
        based_in 'City'
        register_court 'Court'
        registration_number 'RegistragionNumber'
        tax_number 'TaxNumber'
      end

      trait :with_contacts do
        after :create do |address|
          create :contact, institution: address
        end
      end

      trait :with_default_account do
        after :create do |address|
          create :account, address: address, default: true
        end
      end

      factory :complete_project_address, traits: [:with_legals, :with_contacts, :with_default_account]
    end

    factory :person, class: Person do
      salutation 'female'
      first_name 'Vorname'
      type 'Person'
    end

    factory :organization, class: Organization do
      type 'Organization'
      legal_form 'limited'
    end

    factory :contact, class: Contact do
      type 'Contact'
      first_name 'Vorname'
    end
  end
end
