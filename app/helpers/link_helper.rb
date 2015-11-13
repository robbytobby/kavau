module LinkHelper
  def icon_mail_to(email, options = {})
    return if email.blank?
    mail_to email, options do
      content_tag(:span, '', class: 'glyphicon glyphicon-envelope')
    end
  end

  def authorized_icon_link(action, record, options = {})
    return unless condition_met?(options)
    link = Link.new(action, record, current_user, options.reverse_merge(icon: default_icon(action)))
    return unless link.authorized?
    icon_link(link.url, link.options) 
  end

  def authorized_link(action, record, text, options)
    return unless condition_met?(options)
    link = Link.new(action, record, current_user, options.reverse_merge(title: text))
    return unless link.authorized?
    send(link_method(options), text, link.url, link.options) 
  end

  def authorized_show_link(name, record)
    return name unless policy(record).show?
    link_to name, record
  end

  def icon_link(path, options = {})
    options.reverse_merge!(text: '')
    send(icon_link_method(options), path, options)
  end

  #private
  def condition_met?(options)
    options.reverse_merge!(condition: true)
    options[:condition]
  end

  def link_method(options)
    options[:wrap] ? 'wrapped_link_to' : 'link_to'
  end

  def icon_link_method(options)
    options[:wrap] ? 'wrapped_icon_link' : 'nowrap_icon_link'
  end

  def nowrap_icon_link(path, options)
    link_to icon_link_content(options), path, options.except(:text, :icon, :wrap)
  end

  def wrapped_icon_link(path, options)
    content_tag options[:wrap], nowrap_icon_link(path, options)
  end

  def wrapped_link_to(text, path, options)
    content_tag options[:wrap], link_to(text, path, options.except(:wrap, :wrapper_class)), class: options[:wrapper_class]
  end

  def icon_link_content(options)
    content_tag(:span, '', class: "glyphicon glyphicon-#{options[:icon]}") + options[:text].html_safe
  end

  def default_icon(action)
    action_icons[action]
  end

  def action_icons
    {new: 'plus', show: 'eye-open', edit: 'edit', delete: 'trash'}
  end

  class Link
    def initialize(action, record, current_user, options = {})
      @action = action
      @record = record
      @nested_in = options[:nested_in]
      @options = options
      @current_user = current_user
    end

    def authorized?
      Pundit.policy!(@current_user, record).send("#{action}?")
    end

    def record
      @record.is_a?(BasePresenter) ? @record.model : @record 
    end

    def parent
      return unless @nested_in
      return @nested_in unless @nested_in.is_a?(Symbol)
      @record.send(@nested_in)
    end

    def action
      @action
    end

    def url_action
      return unless @action.in? [:new, :edit]
      @action
    end

    def options
      {
        id: id_option,
        title: title_option
      }.merge(@options.except(:path, :condition)).merge(action_dependent_options)
    end

    def id_option
      return unless record.is_a?(ActiveRecord::Base)
      @options[:id] || "#{@action}_#{record.class.name.underscore}_#{record.id}"
    end

    def title_option
      @options[:title] || @options[:text] || I18n.t(@action, scope: 'links')
    end

    def action_dependent_options
      return {} unless @action == :delete
      { method: :delete, data: { confirm: 'Are you sure?' } }
    end
    
    def url
      return @options[:path] if @options[:path]
      return index_path if @action == :index
      [url_action, parent, record].compact
    end

    def index_path
      '/' + record.to_s.pluralize 
    end
  end
end
