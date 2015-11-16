class ManualBalancePresenter < BalancePresenter
  def manually_edited
    Balance.human_attribute_name(:manually_edited)
  end
end

