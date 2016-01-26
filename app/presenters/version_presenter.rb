class VersionPresenter < BasePresenter
  def changed_at
    DateFormatter.new(@model.created_at).formatted_value
  end

  def action_by
    I18n.t("versions.#{@model.event}", by: whodunnit)
  end

  def whodunnit
    [user.first_name, user.name].join(' ')
  end
end
