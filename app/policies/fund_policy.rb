class FundPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  #TODO: bearbeiten + löschen einschränken
  #TODO: getrennte Anlagen für GmbH und Verein

  def index?
    false
  end

  def show?
    false
  end

  def update?
    return false if @record.credit_agreements.any?
    super
  end

  def destroy?
    update?
  end

  def permitted_params
    [:limit, :interest_rate, :issued_at, :project_address_id] 
  end
end
