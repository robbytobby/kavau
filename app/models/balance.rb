class Balance < ActiveRecord::Base
  include ActiveModel::Dirty

  belongs_to :credit_agreement

  after_initialize :set_date
  after_save :update_following
  after_destroy :touch_credit_agreement

  delegate :interest_rate, :creditor, :balances, to: :credit_agreement

  scope :older_than,   ->(from_date){ where(['date > ?', from_date]) }
  scope :younger_than, ->(from_date){ where(['date < ?', from_date]) }

  alias_method :update_end_amount!, :save

  ransacker(:year){ Arel.sql('extract(year from date)') }

  def project_address
    credit_agreement.account.address
  end

  def to_partial_path
    'balances/balance'
  end

  #TODO rename to interests_sum
  def self.interest_sum
    sum(:interests_sum)
  end

  def interests_sum
    self[:interests_sum] ||= calculated_interests_sum
  end

  def start_amount
    last_years_balance.end_amount
  end

  def sum_upto(to_date)
    start_amount + payments.younger_than_inc(to_date).sum('amount * sign')
  end

  def payments
    credit_agreement.payments.this_year_upto(date).where.not(id: @excluded_payment_id)
  end

  def interest_spans
    breakpoints.each_cons(2).map{ |pair| interest_span(pair) }.compact
  end

  def becomes_manual_balance
    self.type  = 'ManualBalance'
    becomes(ManualBalance)
  end

  def without(payment)
    @excluded_payment_id = payment.id
    self
  end

  def pdf
    #TODO: make real - load pdf from file or create
    BalancePdf.new(self).render
  end

  private
    def interest_span(date_pair)
      return if date_pair.uniq.one?
      interest_span_class.new(self, date_pair)
    end

    def last_years_balance
      balances.find_by(date: end_of_last_year) || NullBalance.new(payments.first.try(:date))
    end

    def set_date
      self.date ||= Date.today
    end

    def set_interest_sum
      self.interests_sum = calculated_interests_sum
    end

    def update_following
      following_balance.update_end_amount!
    end

    def following_balance
      balances.older_than(date).first || NullBalance.new(date)
    end

    def calculated_interests_sum
      interest_spans.sum(&:amount)
    end

    def end_of_last_year
      date.prev_year.end_of_year
    end

    def touch_credit_agreement
      credit_agreement.touch
    end
end
