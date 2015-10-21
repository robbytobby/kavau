class ContactPolicy < AddressPolicy

  def show?
    false
  end

  def index?
    false
  end
end

