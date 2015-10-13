module ApplicationHelper
  def cancel_button(path = session[:back_url])
    content_tag(:a, t('links.cancel'), class: 'btn btn-default', href: path, id: 'cancel')
  end

  def back_button(path = session[:back_url])
    content_tag(:a, t('links.back'), class: 'btn btn-default', href: path, id: 'back')
  end

  def edit_button(path)
    content_tag(:a, t('links.edit'), class: 'btn btn-default', href: path, id: 'edit')
  end

  def icon_link_to(icon, path, options = {})
    link_to content_tag(:span, '', class: "glyphicon glyphicon-#{icon}"), path, options
  end

  def present(record)
    klass = "#{record.class}Presenter".constantize
    presenter = klass.new(record, self)
    yield(presenter) if block_given?
  end
end
