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

  def permitted_params
    [:limit, :interest_rate, :issued_at] 
  end
end
