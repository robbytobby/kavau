class Fund < ActiveRecord::Base
  @valid_limits = ['number_of_shares', 'one_year_amount', 'none']

  belongs_to :project_address
  has_many :credit_agreements, ->(fund){ where(interest_rate: interest_rate).joins(:account).where(accounts: {address_id: project_address_id}) }

  validates :interest_rate, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100}, uniqueness: {scope: :project_address}
  validates :issued_at, presence: true
  validates :limit, inclusion: {in: @valid_limits}, presence: true
  validates :project_address_id, presence: true

  def self.valid_limits
    @valid_limits
  end

  def still_available(date = Date.today)
    limit_calculation(date).available
  end

  def limit_calculation(date)
    "#{limit.camelize}Limit".constantize.new(self, date)
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
end
