class NullBalancePresenter < BalancePresenter
  def manually_edited
  end

  def name
    Balance.model_name.human
  end
end

