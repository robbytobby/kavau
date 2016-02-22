module SettingsHelper
  def group_information(category, group)
    {
      category: category,
      group: group,
      help: I18n.t([:settings, :help, category, group].compact.join('.'))
    }
  end
end
