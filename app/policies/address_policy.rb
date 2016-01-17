class AddressPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? scope : scope.project_addresses
    end
  end

  def permitted_params
    [:name, :first_name,
     :street_number, :city, :country_code, :zip,
     :salutation, :title, :email, :phone, :notes]
  end

  def download?
    return false unless user.admin? || user.accountant?
    true
  end

  def download_csv?
    download?
  end
end
