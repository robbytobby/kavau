class Organization < Creditor
  has_many :contacts, foreign_key: :institution_id

  validates :name, :street_number, :zip, :city, :country_code,  presence: true
end
