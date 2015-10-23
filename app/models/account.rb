class Account < ActiveRecord::Base
  include Encryption
  strip_attributes 

  [:name, :bic, :iban, :bank, :owner].each do |attr|
    attr_encrypted attr, key: encryption_key, :mode => :per_attribute_iv_and_salt
  end

  belongs_to :address
  has_many :credit_agreements, dependent: :restrict_with_exception, inverse_of: :account

  before_save :set_address_type

  validates_presence_of :bank, :iban
  validates_presence_of :name, if: ->(account){ account.address.type == 'ProjectAddress' } 
  validates_with IbanValidator
  validates_with BicValidator

  scope :project_accounts, -> { where(address_type: 'ProjectAddress') } 

  def funded_credits_sum
    credit_agreements.funded_credits_sum
  end

  def average_rate_of_interest
    credit_agreements.average_rate_of_interest
  end

  private
    def set_address_type
      self.address_type = address.class.to_s
    end
end
