class ManualInterestSpanPresenter < InterestSpanPresenter
  def calculation
    I18n.t('helpers.manually_calculated')
  end

  def interest_days
  end

  def klass
    'interest manual'
  end
end
