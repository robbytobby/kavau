class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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

  def new?
    create?
  end

  def update?
    user.admin? || user.accountant?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? || user.accountant?
  end

  def delete?
    destroy?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def permitted_params
    []
  end

  def permitted?(attribute)
    permitted_params.include?(attribute)
  end

  private
    def credit_agreement_or_year_terminated?
      record.year_terminated? || record.credit_agreement.terminated?
    end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
