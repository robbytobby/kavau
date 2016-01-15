class PaymentLetterPresenter < LetterPresenter
  def title
    @model.model_name.human
  end
end
