class ProjectAddress < Address
  has_many :contacts, as: :institution

  validates :name, :street_number, :zip, :city, :country_code,  presence: true
end
