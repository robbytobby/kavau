class AddressPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? scope : scope.project_addresses
    end
  end

  def index?
    user.admin? || user.accountant?
  end

  def show?
    user.admin? || user.accountant?
  end

  def create?
    user.admin? || user.accountant?
  end

  def update?
    user.admin? || user.accountant?
  end

  def destroy?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:name, :first_name,
     :street_number, :city, :country_code, :zip,
     :salutation, :title, :email, :phone, :notes]
  end
end
