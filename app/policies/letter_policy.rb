class LetterPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all.order(type: :asc, year: :desc, created_at: :desc)
    end
  end

  def destroy?
    return false if @record.pdfs.any? || @record.pdfs_created?
    super
  end

  def create_pdfs?
    return false if @record.pdfs_created?
    user.admin? || user.accountant?
  end

  def delete_pdfs?
    return false if !@record.pdfs_created?
    user.admin? || user.accountant?
  end

  def get_pdfs?
    return false unless @record.pdfs_created?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:subject, :content, :year]
  end
end
