class ProjectAddress < Address
  strip_attributes
  store_accessor :legal_information, :based_in, :register_court, :registration_number, :ust_id, :tax_number

  has_many :contacts, foreign_key: :institution_id, dependent: :destroy
  has_many :accounts, foreign_key: :address_id, dependent: :destroy
  has_one :default_account,  -> { where(default: true) }, foreign_key: :address_id, class_name: 'Account'
  has_many :credit_agreements, through: :accounts

  validates :name, :street_number, :zip, :city, :country_code, :legal_form, presence: true

  def legal_information_missing?
    missing_legals.any?
  end

  def missing_legals
    (missing_legal_information_keys).compact
  end

  private
    def missing_legal_information_keys
      return required_legal_information_keys unless legal_information
      required_legal_information_keys.select{ |key| key if legal_information[key].blank? }
    end

    def required_legal_information_keys
      ['based_in', 'register_court', 'registration_number']
    end
end
