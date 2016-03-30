class Fund < ActiveRecord::Base
  @valid_limits = ['number_of_shares', 'one_year_amount', 'none']
  validates :interest_rate, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100}, uniqueness: true
  validates :issued_at, presence: true
  validates :limit, inclusion: {in: @valid_limits}, presence: true

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
end
