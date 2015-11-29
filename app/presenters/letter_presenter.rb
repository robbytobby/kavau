class LetterPresenter < BasePresenter
  def confirmation_label
    [@model.model_name.human, @model.id].join(" ")
  end

  def created_at
    I18n.l @model.created_at.to_date
  end

  def type
    [@model.model_name.human, year].join(' ')
  end

  def subject
    return '---' if @model.subject.blank?
    @model.subject
  end

  def subject_line
    return if @model.subject.blank?
    [Letter.human_attribute_name(:subject), subject].join(': ')
  end

  def content
    h.simple_format(@model.content)
  end
end
