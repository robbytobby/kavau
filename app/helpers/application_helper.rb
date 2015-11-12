module ApplicationHelper
  def quit_button(name, path = session[:back_url], options = {})
    action_button(name, path, options)
  end

  def action_button(name, path, options)
    content_tag(
      :a,
      t("links.#{name}"),
      class: "btn btn-default #{options[:class]}",
      href: path, id: "#{name}"
    )
  end

  def present(record)
    klass = "#{record.class}Presenter".constantize
    presenter = klass.new(record, self)
    yield(presenter) if block_given?
  end
end
