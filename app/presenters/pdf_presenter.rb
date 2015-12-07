class PdfPresenter < BasePresenter
  def created_at
    I18n.l(@model.created_at.to_date)
  end

  def confirmation_label
    [I18n.t('helpers.the_letter'), title].join(' ')
  end
end
