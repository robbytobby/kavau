#TODO spec
class CreditAgreementVersion < PaperTrail::Version
  self.table_name = :credit_agreement_versions
  self.sequence_name = :credit_agreement_versions_id_seq

  scope :with_interest_rate_change, ->{ where(interest_rate_changed: true) }
  scope :valid_until_after, ->(date){ where(['valid_until > ?', date]) }
  scope :valid_until_before_or_equal, ->(date){ where(['valid_until <= ?', date]) }
  scope :valid_from_before_or_equal, ->(date){ where(['valid_from <= ?', date]) }

  def self.at(date)
    valid_until_after(date).valid_from_before_or_equal(date).order(created_at: :desc).first
  end

  def self.with_interest_rate_change_between(start_date, end_date)
    where(event: 'update').with_interest_rate_change.valid_until_after(start_date).valid_until_before_or_equal(end_date)
  end

  def to_partial_path
    'versions/version'
  end

  def user
    User.find(whodunnit)
  end
end
