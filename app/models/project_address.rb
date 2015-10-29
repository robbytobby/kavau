class ProjectAddress < Address
  strip_attributes

  has_many :contacts, foreign_key: :institution_id, dependent: :destroy
  has_many :accounts, foreign_key: :address_id, dependent: :destroy
  has_many :credit_agreements, through: :accounts

  validates :name, :street_number, :zip, :city, :country_code, presence: true
end
