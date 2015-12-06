class PdfPolicy < ApplicationPolicy
  def permitted_params
    [:letter_id]
  end
end
