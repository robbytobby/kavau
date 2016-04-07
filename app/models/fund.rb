class Fund < ActiveRecord::Base
  @valid_limits = ['number_of_shares', 'one_year_amount', 'none']

  belongs_to :project_address
  has_many :credit_agreements, ->(fund){ where(interest_rate: interest_rate).joins(:account).where(accounts: {address_id: project_address_id}) }

  validates :interest_rate, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100}, uniqueness: {scope: :project_address}
  validates :issued_at, presence: true
  validates :limit, inclusion: {in: ->(fund){ Fund.valid_limits} }, presence: true
  validates :project_address_id, presence: true

  def self.valid_limits
    return @valid_limits unless enforce_bagatelle_limits
    @valid_limits - ['none']
  end

  def self.regulated_from
    return Date.new(2016, 1, 1) if utilize_transitional_regulation
    Date.new(2015, 7, 10)
  end

  def still_available(date = Date.today)
    limit_calculation(date).available
  end

  def fits_credit_agreement(credit_agreement)
    #Todo Spec
    fits(credit_agreement, credit_agreement.valid_from, exclude: credit_agreement)
  end

  def fits_payment(payment)
    #Todo Spec
    return true if limited_by_number_of_shares?
    fits(payment, payment.date, exclude: payment)
  end

  def fits(record, date, exclude_credit_agreement: nil, exclude: nil )
    #Todo Spec
    limit_calculation(date, exclude).fits(record)
  end

  def error_message_for_credit_agreement(record)
    #Todo Spec
    date = record.valid_from if record.is_a?(CreditAgreement)
    limit_calculation(date).error_message(record)
  end

  def limit_calculation(date, excluded =  nil)
    "#{limit.camelize}Limit".constantize.new(self, date, excluded: excluded)
  end

  def limited_by_number_of_shares?
    limit == 'number_of_shares'
  end

  def limited_by_one_year_amount?
    limit == 'one_year_amount'
  end

  def credit_agreements
    #TODO Altfallregelung
    CreditAgreement.where(interest_rate: interest_rate).joins(:account).where(accounts: {address_id: project_address_id})
  end
  
  private
  def self.enforce_bagatelle_limits
    Setting.kavau.legal_regulation[:enforce_bagatelle_limits]
  end

  def self.utilize_transitional_regulation
    Setting.kavau.legal_regulation[:utilize_transitional_regulation]
  end
end
