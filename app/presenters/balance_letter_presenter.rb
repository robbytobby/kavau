class BalanceLetterPresenter < LetterPresenter
  def title
    [@model.model_name.human, year].join(' ')
  end
end
