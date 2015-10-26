module ApplicationHelper
  def quit_button(name, path = session[:back_url], options = {})
    action_button(name, path, options)
  end

  # UNUSED
  #def edit_button(path, options = {})
  #  action_button(:edit, path, options)
  #end

  def action_button(name, path, options)
    content_tag(:a, t("links.#{name}"), class: "btn btn-default #{options[:class]}" , href: path, id: "#{name}")
  end

  def icon_link_to(icon, path, options = {})
    link_to content_tag(:span, '', class: "glyphicon glyphicon-#{icon}"), path, options
  end

  def icon_mail_to(email, options = {})
    return if email.blank?
    mail_to email, options do
      content_tag(:span, '', class: "glyphicon glyphicon-envelope")
    end
  end

  def mail_link(address)
    (mail_to address.email) if address.email
  end

  def present(record)
    klass = "#{record.class}Presenter".constantize
    presenter = klass.new(record, self)
    yield(presenter) if block_given?
  end
end
