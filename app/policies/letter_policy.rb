class LetterPolicy < ApplicationPolicy

  def create_pdfs?
    return false if @record.pdfs_created?
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
