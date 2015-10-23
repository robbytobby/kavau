class Creditor < Address
  strip_attributes 

  has_many :accounts, foreign_key: :address_id
  has_many :credit_agreements
end
