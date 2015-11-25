class BasePresenter < SimpleDelegator
  def initialize(model, view)
    @model = model
    @view = view
    super(@model)
  end

  def h
    @view
  end

  def model
    @model
  end

  def name
    @model.respond_to?(:name) ? @model.name : @model.class.model_name.human
  end

  def mail_to
    h.mail_to(@model.email) if @model.email
  end

  #def confirmation_label
  #  [@model.model_name.human, @model.id].join(" ")
  #end
end
