json.array!(@credit_agreements) do |credit_agreement|
  json.extract! credit_agreement, :id
  json.url credit_agreement_url(credit_agreement, format: :json)
end
