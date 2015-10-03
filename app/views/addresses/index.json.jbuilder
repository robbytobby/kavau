json.array!(@addresses) do |address|
  json.extract! address, :id, :name, :first_name, :street_number, :city, :country, :salutation, :type
  json.url address_url(address, format: :json)
end
