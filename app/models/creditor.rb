class Creditor < Address
  strip_attributes

  has_many :accounts, foreign_key: :address_id, dependent: :destroy
  has_many :credit_agreements, inverse_of: :creditor, dependent: :restrict_with_exception
  has_many :balances, through: :credit_agreements
  has_many :payments, through: :credit_agreements
  has_many :pdfs, -> { order created_at: :asc }, dependent: :restrict_with_exception
end
