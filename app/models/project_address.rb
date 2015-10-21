class ProjectAddress < Address
  has_many :contacts, foreign_key: :institution_id
  has_many :accounts, foreign_key: :address_id

  validates :name, :street_number, :zip, :city, :country_code,  presence: true
end
