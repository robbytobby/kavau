require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper
  attr_reader :style, :recipient, :sender, :date

  def initialize(sender, recipient)
    super page_definition
    @date = Date.today
    @sender = PdfSender.new(sender, self)
    @recipient = PdfRecipient.new(recipient, self)
    @style = PdfStyles.new(self)
    #TODO set and upload
    @logo = PdfLogo.new(self)
    @first_page_template = get_first_page_template
    @following_page_template = get_following_page_template 
    set_custom_font
    make
  end

  def rendered
    return self.render unless @first_page_template
    pdf_with_template
  end

  def make
    recipient.address
    date_box
    move_cursor_to 15.cm
    stroke_color "7c7b7f"
    layout unless @first_page_template
    content
  end

  private
  def layout
    recipient.address
    repeat :all do
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 6.2.cm) }
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 16.4.cm) }
      @logo.draw
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
    return @first_page_template unless FileTest.exists?(following_page_template_path)
    CombinePDF.load(following_page_template_path).pages[0]
  end

  def following_page_template_path
    #TODO set and upload
    "#{Rails.root}/app/assets/images/briefpapier_gmbh_ff.pdf"
  end

  def get_first_page_template
    return nil unless FileTest.exists?(first_page_template_path)
    CombinePDF.load(first_page_template_path).pages[0]
  end

  def first_page_template_path
    #TODO set and upload
    "#{Rails.root}/app/assets/images/briefpapier_gmbh.pdf"
  end

  def content
  end

  def page_definition
    { 
      page_size: 'A4', 
      page_layout: :portrait,
    #TODO set
      top_margin: 6.cm,
      bottom_margin: 3.5.cm,
      left_margin: 2.cm,
      right_margin: 2.cm 
    }.merge(background_definition)
  end 

  def background_definition
    return {} unless FileTest.exists?(background_path)
    {background: "#{Rails.root}/app/assets/images/stempel.png"}
  end

  def background_path
    #TODO set and upload
    "#{Rails.root}/app/assets/images/stempel.png"
  end

  def set_custom_font
    font_families.update(
      "InfoText" => {
        #TODO set and upload
        normal: "public/fonts/infotext_normal.ttf",
        italic: "public/fonts/infotext_italic.ttf",
        bold: "public/fonts/infotext_bold.ttf",
        bold_italic: "public/fonts/infotext_bold_italic.ttf"
      })
  end
end

