class Account < ActiveRecord::Base
  include Encryption
  strip_attributes

  [:name, :bic, :iban, :bank, :owner].each do |attr|
    attr_encrypted attr, key: encryption_key, mode: :per_attribute_iv_and_salt
  end

  belongs_to :address
  has_many :credit_agreements, dependent: :restrict_with_exception, inverse_of: :account
  has_many :payments, through: :credit_agreements

  delegate :funded_credits_sum, :average_rate_of_interest, to: :credit_agreements
  delegate :belongs_to_project?, to: :address

  before_save :set_address_type

  validates_presence_of :bank, :iban
  validates_presence_of :name, if: :belongs_to_project?
  validates_with IbanValidator
  validates_with BicValidator

  scope :project_accounts, -> { where(address_type: 'ProjectAddress') }

  private
    def set_address_type
      self.address_type = address.class.to_s
    end
end
