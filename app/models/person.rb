class Person < Creditor
  validates :name, :first_name, :street_number, :zip, :city, :country_code,  presence: true

end
