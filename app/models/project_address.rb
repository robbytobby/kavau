class ProjectAddress < Address
  validates :name, :street_number, :zip, :city, :country_code,  presence: true
  has_many :contacts, foreign_key: :organization_id
end
