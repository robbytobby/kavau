class LetterPolicy < ApplicationPolicy

  def permitted_params
    [:subject, :content, :year]
  end
end
