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
    end

    factory :person, class: Person do
      first_name 'Vorname'
      type 'Person'
    end

    factory :organization, class: Organization do
      type 'Organization'
    end

    factory :contact, class: Contact do
      type 'Contact'
      first_name 'Vorname'
    end
  end
end
