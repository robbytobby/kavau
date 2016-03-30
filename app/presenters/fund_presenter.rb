class FundPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  def interest_rate
    number_to_percentage @model.interest_rate
  end

  def issued_at
    I18n.l @model.issued_at
  end
  
  def limit
    I18n.t @model.limit, scope: 'fund_limits'
  end

  def confirmation_label
    I18n.t("confirmation_label.#{@model.model_name.name.underscore}", rate: interest_rate)
  end
end
