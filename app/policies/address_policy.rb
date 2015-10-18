class AddressPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? scope.all : scope.none
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
    [:name, :first_name, :street_number, :city, :country_code, :salutation, :title, :email, :phone, :zip, :notes]
  end
end
