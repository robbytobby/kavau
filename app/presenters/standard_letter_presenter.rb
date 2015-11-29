class StandardLetterPresenter < LetterPresenter
  def title
    [@model.model_name.human, id].join(' ')
  end
end
