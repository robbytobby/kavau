class Creditor < Address
  has_many :accounts, foreign_key: :address_id
end
