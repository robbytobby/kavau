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

  def changes
    changeset.map{ |entry| ChangePresenter.new(item_type, *entry) }
  end

  def user
    User.find_by(id: @model.whodunnit) || NullUser.new
  end

  class NullUser
    def first_name
      I18n.t('activerecord.attributes.null_user.first_name')
    end

    def name
      I18n.t('activerecord.attributes.null_user.name')
    end
  end
end
