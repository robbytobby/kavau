module LinkHelper
  def icon_mail_to(email, options = {})
    return if email.blank?
    mail_to email, options do
      content_tag(:span, '', class: 'glyphicon glyphicon-envelope')
    end
  end

  def mail_link(address)
    (mail_to address.email) if address.email
  end

  def icon_link_to(icon, path, options = {})
    link_to content_tag(:span, '', class: "glyphicon glyphicon-#{icon}"),
            path,
            options
  end

  def authorized_show_link(name, record)
    return name unless policy(record).show?
    link_to name, record
  end

  def authorized_new_icon_link(record, nested_in: nil, icon: 'plus')
    authorized_icon_link(Link.new(:new, record, nested_in), icon)
  end

  def authorized_show_icon_link(record, nested_in: nil, icon: 'eye-open')
    authorized_icon_link(Link.new(:show, record, nested_in), icon)
  end

  def authorized_edit_icon_link(record, nested_in: nil, icon: 'edit')
    authorized_icon_link(Link.new(:edit, record, nested_in), icon)
  end

  def authorized_delete_icon_link(record, nested_in: nil, icon: 'trash')
    authorized_icon_link(Link.new(:delete, record, nested_in), icon)
  end

  private
  def authorized_icon_link(link, icon, opts = {})
    return unless policy(link.record).send("#{link.action}?")
    icon_link_to(icon, link.url, link.opts.merge(opts)) 
  end

  class Link
    def initialize(action, record, nested_in = nil)
      @action = action
      @record = record
      @nested_in = nested_in
    end

    def record
      @record.is_a?(BasePresenter) ? @record.model : @record 
    end

    def parent
      return unless @nested_in
      @record.send(@nested_in)
    end

    def action
      @action
    end

    def url_action
      return unless @action.in? [:new, :edit]
      @action
    end

    def opts
      {
        id: "#{@action}_#{record.class.name.underscore}_#{record.id}",
        title: I18n.t(@action, scope: 'links')
      }.merge(action_dependent_opts)
    end

    def action_dependent_opts
      return {} unless @action == :delete
      { method: :delete, data: { confirm: 'Are you sure?' } }
    end
    
    def url
      [url_action, parent, record].compact
    end
  end
end
