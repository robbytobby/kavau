class CreditAgreementPresenter < BasePresenter
  def amount
    h.number_to_currency(@model.amount)
  end

  def interest_rate
    h.number_to_percentage(@model.interest_rate)
  end

  def cancellation_period
    h.t('months', count: @model.cancellation_period)
  end
end

