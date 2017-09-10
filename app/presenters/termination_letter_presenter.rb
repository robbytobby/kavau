class TerminationLetterPresenter < LetterPresenter
  def title
    @model.model_name.human 
  end
end
