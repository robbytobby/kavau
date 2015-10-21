class Account < ActiveRecord::Base
  include Encryption
  belongs_to :address
  before_save :set_address_type

  scope :project_accounts, -> { where(address_type: 'ProjectAddress') } 

  [:name, :bic, :iban, :bank, :owner].each do |attr|
    attr_encrypted attr, key: encryption_key, :mode => :per_attribute_iv_and_salt
  end

  validates_presence_of :bank, :iban

  private
    def set_address_type
      self.address_type = address.class.to_s
    end
end
