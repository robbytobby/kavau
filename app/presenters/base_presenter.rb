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
end
