module SettingsHelper
  def group_information(category, group)
    {
      category: category,
      group: group,
      help: I18n.t([:settings, :help, category.downcase, group.downcase].compact.join('.'))
    }
  end
end
