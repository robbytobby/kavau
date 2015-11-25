class MissingInformationError < StandardError
  def initialize(object)
    @address = object 
  end

  def address
    @address
  end
end
