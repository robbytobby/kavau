FactoryGirl.define do
  factory :address do
    type 'Address'
    name 'Test Name' 
    street_number "Test Street"
    zip "Test Zip"
    city "Test City"
    country_code "DE"

    factory :project_address do
      type "ProjectAddress"
    end

    factory :person do
      first_name 'Vorname'
      type 'Person'
    end

    factory :organization do
      type 'Organization'
    end
  end
end
