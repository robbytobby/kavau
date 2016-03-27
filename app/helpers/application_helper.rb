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

  def flash_class(type)
    "alert alert-#{type}"
  end

  def close_button_attributes
    { class: "close", aria: {hidden: "true"}, data: {dismiss: "alert"}, type: "button" }
  end

  def style_xlsx(sheet, style, options = {})
    header = style.add_style b: true, bg_color: 'dddddd'
    money = style.add_style format_code: '0.00 €', font_name: 'Arial'
    percent = style.add_style format_code: '0.00 %', font_name: 'Arial'

    money_cols = [options[:money]].flatten.compact
    percent_cols = [options[:percent]].flatten.compact

    money_cols.each{ |col| sheet.col_style col, money }
    percent_cols.each{ |col| sheet.col_style col, percent }
    sheet.row_style 0, header
  end

  def config
    Setting.kavau
  end
end
