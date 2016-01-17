class ContactPolicy < AddressPolicy
  def show?
    false
  end

  def index?
    false
  end

  def download?
    false
  end

  def download_csv?
    false
  end
end
