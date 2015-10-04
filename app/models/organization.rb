class Organization < Creditor
  validates :name, :street_number, :zip, :city, :country_code,  presence: true
end
