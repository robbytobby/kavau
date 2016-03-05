require "prawn/measurement_extensions"
require "concerns/building_block"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include BuildingBlock
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper
  attr_reader :style, :recipient, :sender, :date

  def initialize(sender, recipient)
    check_templates
    check_custom_fonts
    super page_definition
    @date = Date.today
    @sender = PdfSender.new(sender, self)
    @recipient = PdfRecipient.new(recipient, self)
    @style = PdfStyles.new(self)
    @logo = PdfLogo.new(self)
    @first_page_template = get_first_page_template
    @following_page_template = get_following_page_template 
    set_custom_font if use_custom_font?
    make
  end

  def rendered
    return self.render unless @first_page_template
    pdf_with_template
  end

  def make
    recipient.address
    date_box
    layout unless @first_page_template
    move_cursor_to 15.cm
    stroke_color "7c7b7f"
    content
  end

  private
  def layout
    @sender.over_address_line
    @logo.draw 
    repeat :all do
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 6.2.cm) }
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 16.4.cm) }
      @sender.footer
    end
  end

  def pdf_with_template
    pdf = CombinePDF.parse(self.render)
    pdf.pages(nil).each_with_index do |page, index| 
      page >> (index == 0 ? @first_page_template : @following_page_template)
    end
    pdf.to_pdf
  end

  def get_following_page_template
    return @first_page_template unless following_page_template_path
    CombinePDF.load(following_page_template_path).pages[0]
  end

  def following_page_template_path
    config[:templates][:following_page_template]
  end

  def get_first_page_template
    return nil unless first_page_template_path
    CombinePDF.load(first_page_template_path).pages[0]
  end

  def first_page_template_path
    config[:templates][:first_page_template]
  end

  def content
  end

  def page_definition
    {page_size: 'A4', page_layout: :portrait}.merge(margins).merge(background_definition)
  end 

  def background_definition
    {background: config[:templates][:watermark]}
  end

  def margins
    config[:margins].inject({}){ |hash, values|
      hash[values.first] = values.last.cm
      hash
    }
  end

  def set_custom_font
    font_families.update(
      'CustomFont' => {
        #TODO set and upload
        normal: config[:custom_font][:normal],
        italic: config[:custom_font][:italic],
        bold: config[:custom_font][:bold],
        bold_italic: config[:custom_font][:bold_italic]
      })
  end

  def check_templates
    [:logo, :watermark, :first_page_template, :following_page_template].each do |config_key|
      file_check(:templates, config_key)
    end
  end

  def check_custom_fonts
    [:normal, :italic, :bold, :bold_italic].each do |config_key|
      file_check(:custom_font, config_key)
    end
  end

  def file_check(group, key)
    return true if config[group][key].nil?
    return true if FileTest.exists?(config[group][key])
    raise MissingTemplateError.new(group: group, key: key)
  end
end

