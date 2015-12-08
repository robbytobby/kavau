class Organization < Creditor
  strip_attributes

  has_many :contacts, foreign_key: :institution_id, dependent: :destroy

  validates :name, :street_number, :zip, :city, :country_code, :legal_form, presence: true
end
